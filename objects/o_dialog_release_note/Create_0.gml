/// @description init
event_inherited();

#region data
	dialog_w = ui(720);
	dialog_h = ui(480);
	destroy_on_click_out = true;
	
	note = "";
	
	var _link = $"https://gist.githubusercontent.com/Ttanasart-pt/f21a140906a60c6e12c99ebfecec1645/raw/{VERSION_STRING}";
	note_get = http_get(_link);
	
	sp_note = new scrollPane(dialog_w - ui(80), dialog_h - ui(88), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		BLEND_ALPHA_MULP
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
						
						draw_sprite_stretched_ext(THEME.group_label, 1, xx, yy - ui(4), ww, _h + ui(8), COLORS._main_icon, 1);
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
						
						draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
						for( var j = 1, m = array_length(_stx); j < m; j++ ) {
							var _word = (j > 1? " " : "") + _stx[j];
							
							if(_x + string_width(_word) > ww) {
								yy += line_get_height();
								_x  = _lx;
							}
							
							if(string_char_at(_word, 1) == "[")
								draw_set_color(COLORS._main_text_accent);
							else
								draw_set_color(COLORS._main_text);
							
							draw_text(_x, _y + yy, _word);
							_x += string_width(_word);
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
		
		BLEND_NORMAL
		return yy + ui(64);
	})
#endregion