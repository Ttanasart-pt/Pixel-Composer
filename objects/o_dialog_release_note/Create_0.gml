/// @description init
event_inherited();

#region data
	dialog_w = ui(720);
	dialog_h = ui(480);
	padding  = ui(12);
	destroy_on_click_out = true;
	
	pages = [ "Release note", "Downloads" ];
	page  = 0;
	
	content_w = dialog_w - (padding + ui(8)) * 2;
	content_h = dialog_h - ui(48 + 16) - padding;
#endregion

#region note
	note_get = http_get($"https://gist.githubusercontent.com/Ttanasart-pt/f21a140906a60c6e12c99ebfecec1645/raw/{VERSION_STRING}");
	note     = "";
	
	sp_note = new scrollPane(content_w, content_h, function(_y, _m) {
		draw_clear_alpha(COLORS.dialog_splash_badge, 1);
		
		var xx = ui(8);
		var yy = ui(8);
		var ww = sp_note.surface_w - ui(16);
		var txt = note;
		
		var lines = string_split(txt, "\n");
		for( var i = 0, n = array_length(lines); i < n; i++ ) {
			var line  = lines[i];
			var _stx  = string_split(string_trim(line), " ");
			var _line = line;
			
			if(array_length(_stx) <= 1) {
				draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
				draw_text_line(xx + 0, _y + yy, line, -1, ww);
				
				yy += string_height_ext(_line, -1, ww);
			} else {
				var _cont = array_create(array_length(_stx) - 1);
				for( var j = 1, m = array_length(_stx); j < m; j++ ) 
					_cont[j - 1] = _stx[j];
				
				_line = string_join_ext(" ", _cont);
				
				switch(_stx[0]) {
					case "#" :
						draw_set_text(f_h3, fa_left, fa_top, COLORS._main_text_sub);
						yy += (!!i) * ui(16);
						draw_text_line(xx, _y + yy, _line, -1, ww);
					
						yy += ui(4);
						break;
					case "##" :
						draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text_sub);
						var  _h = string_height_ext(_line, -1, ww);
						yy += (!!i) * ui(16);
						
						draw_sprite_stretched_ext(THEME.box_r5_clr, 1, xx, _y + yy - ui(4), ww, _h + ui(8), COLORS._main_icon, 1);
						draw_text_line(xx + ui(16), _y + yy, _line, -1, ww);
						yy += ui(8);
						break;
					case "###" :
						draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_accent);
						yy += (!!i) * ui(8);
						draw_text_line(xx + ui(16), _y + yy, _line, -1, ww);
						yy += ui(4);
						break;
					case "-" :
						var _x = xx + ui(28);
						if(string_char_at(line, 1) == "\t")
							_x += ui(16);
						
						draw_sprite_ui_uniform(THEME.text_bullet, 0, _x - ui(12), _y + yy + ui(18), 1, COLORS._main_icon);
						
						var _lx = _x;
						var _topic = false;
						
						draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
						for( var j = 1, m = array_length(_stx); j < m; j++ ) {
							var _word = (j > 1? " " : "") + _stx[j];
							
							if(_x + string_width(_word) > ww) {
								yy += line_get_height();
								_x  = _lx;
							}
							
							if(string_char_at(_word, 1) == "[")
								_topic = true;
								
							draw_set_color(_topic? COLORS._main_text_accent : COLORS._main_text);
							draw_text_add(_x, _y + yy, _word);
							_x += string_width(_word);
							
							if(string_char_last(_word) == "]")
								_topic = false;
						}
						
						yy += line_get_height();
						break;
					default :
						draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
						draw_text_line(xx + 0, _y + yy, _line, -1, ww);
						break;
				}
				
				if(_stx[0] != "-")
					yy += string_height_ext(_line, -1, ww);
			}
		}
		
		return yy + ui(64);
	})
#endregion

#region downloads
	dl_get = http_get(global.KEYS.download_links);
	dls    = [];
	downloading = {};
	
	sp_dl = new scrollPane(content_w, content_h, function(_y, _m) {
		draw_clear_alpha(COLORS.dialog_splash_badge, 1);
		
		var xx = ui(8);
		var yy = _y + ui(8);
		
		var ww = sp_dl.surface_w - ui(16);
		var hh = ui(56);
		
		for( var i = 0, n = array_length(dls); i < n; i++ ) {
			var dl = dls[i];
			var vr = dl.version;
			hh     = dl.status == 0? ui(36) : ui(56);
			
			var hov = sHOVER && point_in_rectangle(_m[0], _m[1], xx, yy, xx + ww, yy + hh);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 0, xx, yy, ww, hh);
			
			if(dl.status == 0 && hov) {
				draw_sprite_stretched_ext(THEME.ui_panel, 1, xx, yy, ww, hh, COLORS._main_accent, 1);
				if(mouse_press(mb_left, sFOCUS)) {
					var path = get_save_filename_ext("Compressed zip (.zip)| *.zip", $"PixelComposer {vr}.zip", "", "Download location");
					if(path != "") {
						dl.status        = 1;
						dl.download_path = path;
						
						var _get = http_get_file(dl.link, path);
						downloading[$ _get] = dl;
					}
				}
			
			} else if(dl.status == 2 && hov) {
				draw_sprite_stretched_ext(THEME.ui_panel, 1, xx, yy, ww, hh, COLORS._main_accent, 1);
				if(mouse_press(mb_left, sFOCUS)) 
					shellOpenExplorer(filename_dir(dl.download_path));
			
			} else if(dl.status == -1 && hov) {
				draw_sprite_stretched_ext(THEME.ui_panel, 1, xx, yy, ww, hh, COLORS._main_accent, 1);
				if(mouse_press(mb_left, sFOCUS)) 
					url_open(dl.download_path);
				
			} else 
				draw_sprite_stretched_ext(THEME.ui_panel, 1, xx, yy, ww, hh, COLORS.node_display_text_frame_outline, 1);
			
			draw_set_text(f_p0b, fa_left, fa_top, dl.status == 2? COLORS._main_text : COLORS._main_text_sub);
			draw_text(xx + ui(8), yy + ui(8), vr);
			
			if(dl.status == 1) {
				var _bw  = ww - ui(16);
				var _bh  = ui(12);
				var _bx  = xx + ui(8);
				var _by  = yy + hh - _bh - ui(8);
				var _prg = dl.size_total == 0? 0 : dl.size_downloaded / dl.size_total;
				
				draw_sprite_stretched(THEME.progress_bar, 0, _bx, _by, _bw, _bh);
				draw_sprite_stretched(THEME.progress_bar, 1, _bx, _by, _bw * _prg, _bh);
				
			} else if(dl.status == 2) {
				draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
				draw_text_cut(xx + ui(8), yy + ui(32), dl.download_path, ww - ui(16));
				
			} else if(dl.status == -1) {
				draw_set_text(f_p1, fa_left, fa_top, COLORS._main_value_negative);
				draw_text_cut(xx + ui(8), yy + ui(32), $"HTTP get error : open the download link in browser.", ww - ui(16));
			}
			
			if(dl.status) {
				draw_set_text(f_p1, fa_right, fa_top, COLORS._main_text_sub);
				draw_text(xx + ww - ui(8), yy + ui(10), string_byte_format(dl.size_total));
				
			}
			
			yy += hh + ui(4);
		}
		
		return yy + ui(64) - _y;
	})
#endregion