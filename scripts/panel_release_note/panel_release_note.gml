function Panel_Release_Note() : PanelContent() constructor {
	title    = "Release note";
	w        = ui(800);
	h        = ui(560);
	auto_pin = true;
	
	#region data
		page_width = ui(132);
		pages      = [ "Release note", "Downloads" ];
		page       = 0;
		
		content_w = w - padding - page_width;
		content_h = h - padding * 2;
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
		dl_get       = http_get(global.KEYS.download_links);
		dls          = [];
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
				var hov  = pHOVER && point_in_rectangle(_m[0], _m[1], xx, yy, xx + ww, yy + hh);
				
				draw_sprite_stretched(THEME.ui_panel_bg, 0, xx, yy, ww, hh);
				draw_sprite_stretched_ext(THEME.ui_panel, 1, xx, yy, ww, hh, COLORS.node_display_text_frame_outline, 1);
				
				if(dl.status == 0) {
					if(hov) {
						draw_sprite_stretched_ext(THEME.ui_panel, 1, xx, yy, ww, hh, COLORS._main_accent, 1);
						if(mouse_press(mb_left, pFOCUS)) 
							toggleDownload(dl);
						
						if(mouse_press(mb_right, pFOCUS)) {
							dl_selecting = dl;
							menuCall("", [
								menuItem("Download", function() /*=>*/ {return toggleDownload(dl_selecting)}),
								menuItem("Open URL", function() /*=>*/ {return url_open(dl_selecting.link)}),
							]);
						}
					}
					
				} else if(dl.status == 2 && hov) {
					draw_sprite_stretched_ext(THEME.ui_panel, 1, xx, yy, ww, hh, COLORS._main_accent, 1);
					if(mouse_press(mb_left, pFOCUS)) 
						shellOpenExplorer(filename_dir(dl.download_path));
					
					if(mouse_press(mb_right, pFOCUS)) {
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
					if(mouse_press(mb_left, pFOCUS)) 
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
					draw_text_cut(xx + ui(8), yy + ui(24), dl.download_path, ww - ui(16));
					
				} else if(dl.status == -1) {
					draw_set_text(f_p3, fa_left, fa_top, COLORS._main_value_negative);
					draw_text_cut(xx + ui(8), yy + ui(24), $"HTTP get error : open the download link in browser.", ww - ui(16));
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
	
	static asyncCallback = function(async_load) {
		var _id     = ds_map_find_value(async_load, "id");
		var _status = ds_map_find_value(async_load, "status");
		
		if (_id == note_get) {
		    if (_status == 0) {
		        note   = ds_map_find_value(async_load, "result");
		        noteMd = markdown_parse(note);
				alarm[0] = 1;
			}
			
		} else if (_id == dl_get) {
			if (_status == 0) {
		        var res = ds_map_find_value(async_load, "result");
				dls = json_try_parse(res, []);
				
				for( var i = 0, n = array_length(dls); i < n; i++ ) {
					var _v = dls[i].version;
					
					dls[i].status            = 0;
					dls[i].download_path     = "";
					
					dls[i].size_total      = 0;
					dls[i].size_downloaded = 0;
					
					if(struct_has(PREFERENCES.versions, _v)) {
						var _path =  PREFERENCES.versions[$ _v];
						
						if(file_exists(_path)) {
							dls[i].status          = 2;
							dls[i].download_path   = _path;
							dls[i].size_total      = file_size(_path);
						}
					}
				}
			}
			
		} else if (struct_has(downloading, _id)) {
			var dl = downloading[$ _id];
			
			if(_status == 0) {
				if(dl.size_downloaded < 10000) {
					dl.status = -1;
					
				} else {
					dl.status = 2;
					PREFERENCES.versions[$ dl.version] = dl.download_path;
					PREF_SAVE();
				}
				
			} else if(_status == 1) {
				if(ds_map_exists(async_load, "http_status")) {
					var _http_status   = ds_map_find_value(async_load, "http_status");
					print(_http_status);
				}
				
				dl.size_total      = ds_map_find_value(async_load, "contentLength");
				dl.size_downloaded = ds_map_find_value(async_load, "sizeDownloaded");
				
			} else 
				noti_warning($"HTTP get error {_status}");
		}
	}
	
	function drawContent(panel) {
	    draw_clear_alpha(COLORS.panel_bg_clear, 1);
	    
		var _x = ui(16);
		var _y = ui(16);
		var hg = line_get_height(f_p1, 8);
		
		draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text);
		
		for( var i = 0, n = array_length(pages); i < n; i++ ) {
			draw_set_font(f_p0b);
			var r  = __txt(pages[i]);
			var rw = string_width(r);
			
			var px = _x - ui(8);
			var py = _y - ui(4);
			var pw = page_width - ui(16);
			var ph = hg;
			
			if(pHOVER && point_in_rectangle(mx, my, px, py, px + pw, py + ph - 1)) {
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, px, py, pw, ph, CDEF.main_white, 1);
				
				if(i != page && mouse_press(mb_left, pFOCUS))
					page = i;
			}
		
			draw_set_font(i == page? f_p1b : f_p1);
			draw_set_color(i == page? COLORS._main_text : COLORS._main_text_sub);
			draw_text(_x, _y, r);
				
			_y += hg;
		}
		
		var _px = page_width;
		var _py = padding;
		var _pw = w - padding - page_width;
		var _ph = h - padding - padding;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, _px, _py, _pw, _ph);
		
		content_w = _pw - ui(16);
		content_h = _ph - ui(16);
		
		if(page == 0) {
			sp_note.setFocusHover(pFOCUS, pHOVER);
			sp_note.verify(content_w, content_h);
			sp_note.drawOffset(_px + ui(8), _py + ui(8), mx, my);
			
		} else if(page == 1) {
			sp_dl.setFocusHover(pFOCUS, pHOVER);
			sp_dl.verify(content_w, content_h);
			sp_dl.drawOffset(_px + ui(8), _py + ui(8), mx, my);
			
		}
	    
	}
}