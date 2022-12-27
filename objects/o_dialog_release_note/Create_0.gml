/// @description init
event_inherited();

#region data
	dialog_w = ui(720);
	dialog_h = ui(480);
	destroy_on_click_out = true;
	
	note = "";
	
	var link = "https://gist.githubusercontent.com/Ttanasart-pt/e7ab670299ce6b00cfd632646f3ac9a8/raw/1.0.0";
	note_get = http_get(link);
	
	sp_note = new scrollPane(dialog_w - ui(80), dialog_h - ui(88), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		BLEND_OVER
		var yy = 0;
		var txt = note;
		
		while(string_length(txt) > 0) {
			var nl   = string_pos("\n", txt);
			var line = string_copy(txt, 1, nl - 1);
			var tab  = 1;
			while(string_char_at(line, tab) == " " && tab < string_length(line)) tab++;
			line = string_copy(line, tab, string_length(line) - tab + 1);
			
			if(nl == 0) {
				line = txt;
				txt = "";
			} else {
				txt = string_copy(txt, nl + 1, string_length(txt) - nl);
			}
			
			var sp = string_pos(" ", line);
			var md = string_copy(line, 1, sp - 1);
			var ww = dialog_w - ui(128);
			var xx = (tab - 1) * ui(8);
			
			switch(md) {
				case "#" :
					draw_set_text(f_h3, fa_left, fa_top, COLORS._main_text_title);
					line = string_copy(line, sp + 1, string_length(line) - sp);
					yy += ui(16);
					draw_text_ext(xx, _y + yy, line, -1, ww);
					
					yy += ui(4);
					break;
				case "##" :
					draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text_title);
					line = string_copy(line, sp + 1, string_length(line) - sp);
					yy += ui(8);
					draw_text_ext(xx + ui(16), _y + yy, line, -1, ww);
					yy += ui(4);
					break;
				case "###" :
					draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_accent);
					line = string_copy(line, sp + 1, string_length(line) - sp);
					yy += ui(8);
					draw_text_ext(xx + ui(16), _y + yy, line, -1, ww);
					yy += ui(4);
					break;
				case "-" :
					draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
					line = string_copy(line, sp + 1, string_length(line) - sp);
					draw_sprite_ui_uniform(THEME.text_bullet, 0, xx + ui(16), _y + yy + ui(10), 1, COLORS._main_icon);
					draw_text_ext(xx + ui(28), _y + yy, line, -1, ww);
					break;
				case "+" :
					draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
					line = string_copy(line, sp + 1, string_length(line) - sp);
					draw_sprite_ui_uniform(THEME.text_bullet, 1, xx + ui(16), _y + yy + ui(10), 1, COLORS._main_value_positive);
					draw_text_ext(xx + ui(28), _y + yy, line, -1, ww);
					break;
				default :
					draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
					draw_text_ext(xx + 0, _y + yy, line, -1, ww);
					break;
			}
			
			yy += string_height_ext(line, -1, ww);
		}
		
		BLEND_NORMAL
		return yy + ui(64);
	})
#endregion