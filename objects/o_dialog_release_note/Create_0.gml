/// @description init
event_inherited();

#region data
	dialog_w = ui(800);
	dialog_h = ui(560);
	padding  = ui(12);
	dialog_resizable     = true;
	destroy_on_click_out = true;
	
	page_width = ui(132);
	pages      = [ "Release note", "Downloads" ];
	page       = 0;
	
	content_w = dialog_w - padding - page_width;
	content_h = dialog_h - padding * 2;
#endregion

#region note
	note_pre = "https://gist.githubusercontent.com/Ttanasart-pt/f21a140906a60c6e12c99ebfecec1645/raw/";
	note_dir = "https://raw.githubusercontent.com/Ttanasart-pt/Pixel-Composer/refs/heads/main/releases/"
	note_get = http_get(note_dir + RELEASE_STRING + ".md");
	note     = "";
	noteMd   = [];
	
	sp_note = new scrollPane(content_w, content_h, function(_y, _m) {
		draw_clear_alpha(COLORS.dialog_splash_badge, 1);
		
		var xx = ui(8);
		var yy = ui(8) + _y;
		var ww = sp_note.surface_w - ui(16);
		var hh = markdown_draw(noteMd, xx, yy, ww);
		
		return hh + ui(64);
	})
#endregion

#region downloads
	dl_get = http_get(DOWNLOAD_LINKS);
	dls    = [];
	downloading  = {};
	dl_selecting = noone;
	
	function toggleDownload(dl) {
		var  vers = dl.version;
		var _path = get_save_filename_ext("Compressed zip (.zip)| *.zip", $"PixelComposer {vers}.zip", "", "Download location");
		var _dir  = filename_dir(_path);
		
		if(_dir != "") {
			dl.status        = 1;
			dl.download_path = _path;
			
			var _get = http_get_file(dl.link, _path);
			downloading[$ _get] = dl;
		}
	}
	
	sp_dl = new scrollPane(content_w, content_h, function(_y, _m) {
		draw_clear_alpha(COLORS.dialog_splash_badge, 1);
		
		var bw = 0 * ui(96);
		
		var xx = ui(8);
		var yy = _y + ui(8);
		var ww = sp_dl.surface_w - ui(16) - bw - ui(4);
		
		for( var i = 0, n = array_length(dls); i < n; i++ ) {
			var dl   = dls[i];
			var vers = dl.version;
			var type = dl.type;
			var hh   = dl.status == 0? ui(28) : ui(48);
			var hov  = sHOVER && point_in_rectangle(_m[0], _m[1], xx, yy, xx + ww, yy + hh);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 0, xx, yy, ww, hh);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, xx, yy, ww, hh, COLORS.node_display_text_frame_outline, 1);
			
			if(dl.status == 0) {
				if(hov) {
					draw_sprite_stretched_ext(THEME.ui_panel, 1, xx, yy, ww, hh, COLORS._main_accent, 1);
					if(mouse_press(mb_left, sFOCUS)) 
						toggleDownload(dl);
					
					if(mouse_press(mb_right, sFOCUS)) {
						dl_selecting = dl;
						menuCall("", [
							menuItem("Download", function() /*=>*/ {return toggleDownload(dl_selecting)}),
							menuItem("Open URL", function() /*=>*/ {return url_open(dl_selecting.link)}),
						]);
					}
				}
				
				// var _bx = xx + ww + ui(4);
				// var _by = yy;
				// var _bw = bw;
				// var _bh = hh;
				// if(buttonInstantGlass(sHOVER, sFOCUS, _m[0], _m[1], _bx, _by, _bw, _bh, __txt("Download"), .1) == 2) {
					
				// }
				
			} else if(dl.status == 2 && hov) {
				draw_sprite_stretched_ext(THEME.ui_panel, 1, xx, yy, ww, hh, COLORS._main_accent, 1);
				if(mouse_press(mb_left, sFOCUS)) 
					shellOpenExplorer(filename_dir(dl.download_path));
				
				if(mouse_press(mb_right, sFOCUS)) {
					dl_selecting = dl;
					menuCall("", [
						menuItem("Open",   function() /*=>*/ {return shellOpenExplorer(filename_dir(dl_selecting.download_path))}),
						menuItem("Delete", function() /*=>*/ {
							file_delete(dl_selecting.download_path);
							dl_selecting.download_path = "";
							dl_selecting.status = 0;
						}),
						menuItem("Re-Download", function() /*=>*/ {
							file_delete(dl_selecting.download_path);
							var _path = dl_selecting.download_path;
							dl_selecting.status = 1;
							
							var _get = http_get_file(dl_selecting.link, _path);
							downloading[$ _get] = dl_selecting;
						}),
					]);
				}
				
			} else if(dl.status == -1 && hov) {
				draw_sprite_stretched_ext(THEME.ui_panel, 1, xx, yy, ww, hh, COLORS._main_accent, 1);
				if(mouse_press(mb_left, sFOCUS)) 
					url_open(dl.link);
				
			}
			
			var tx = xx + ui(8);
			
			switch(type) {
				case "stable" : 
					draw_set_text(f_p1b, fa_left, fa_top, COLORS._main_text_accent); 
					tx = xx + ui(8);
					break;
					
				case "beta"   : 
					draw_set_text(f_p2,  fa_left, fa_top, COLORS._main_text);        
					tx = xx + ui(20);
					break;
					
				case "alpha"  : 
					draw_set_text(f_p3,  fa_left, fa_top, COLORS._main_text);        
					tx = xx + ui(20);
					break;
			}
			
			draw_set_alpha(dl.status == 2? 1 : .5);
			draw_text(tx, yy + ui(4), vers);
			draw_set_alpha(1);
			
			if(dl.status == 1) {
				var _bw  = ww - ui(16);
				var _bh  = ui(12);
				var _bx  = xx + ui(8);
				var _by  = yy + hh - _bh - ui(8);
				var _prg = dl.size_total == 0? 0 : dl.size_downloaded / dl.size_total;
				
				draw_sprite_stretched(THEME.progress_bar, 0, _bx, _by, _bw, _bh);
				draw_sprite_stretched(THEME.progress_bar, 1, _bx, _by, _bw * _prg, _bh);
				
			} else if(dl.status == 2) {
				draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
				
				var _scis = gpu_get_scissor();
				gpu_set_scissor(xx + ui(8), yy + ui(24), ww - ui(16), hh);
				draw_text_add(xx + ui(8), yy + ui(24), dl.download_path, ww - ui(16));
				gpu_set_scissor(_scis);
				
			} else if(dl.status == -1) {
				draw_set_text(f_p3, fa_left, fa_top, COLORS._main_value_negative);
				
				var _scis = gpu_get_scissor();
				gpu_set_scissor(xx + ui(8), yy + ui(24), ww - ui(16), hh);
				draw_text_add(xx + ui(8), yy + ui(24), $"HTTP get error : open the download link in browser.");
				gpu_set_scissor(_scis);
			}
			
			if(dl.status) {
				draw_set_text(f_p3, fa_right, fa_top, COLORS._main_text_sub);
				draw_text(xx + ww - ui(8), yy + ui(6), string_byte_format(dl.size_total));
				
			}
			
			yy += hh + ui(4);
		}
		
		return yy + ui(64) - _y;
	})
#endregion