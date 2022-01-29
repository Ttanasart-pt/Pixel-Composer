/// @description init
event_inherited();

#region data
	dialog_w = 600;
	dialog_h = 360;
	destroy_on_click_out = true;
	
	note = "";
	
	var link = "https://gist.githubusercontent.com/Ttanasart-pt/e7ab670299ce6b00cfd632646f3ac9a8/raw/0.9.0";
	node_get = http_get(link);
	
	sp_note = new scrollPane(dialog_w - 80, dialog_h - 88, function(_y, _m) {
		draw_clear_alpha(c_ui_blue_black, 0);
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
			var ww = dialog_w - 128;
			var xx = (tab - 1) * 8;
			
			switch(md) {
				case "#" :
					draw_set_text(f_h5, fa_left, fa_top, c_ui_blue_grey);
					line = string_copy(line, sp + 1, string_length(line) - sp);
					yy += 16;
					draw_text_ext(xx, _y + yy, line, -1, ww);
					
					yy += 4;
					break;
				case "##" :
					draw_set_text(f_p0b, fa_left, fa_top, c_ui_blue_ltgrey);
					line = string_copy(line, sp + 1, string_length(line) - sp);
					yy += 8;
					draw_text_ext(xx + 16, _y + yy, line, -1, ww);
					yy += 4;
					break;
				case "-" :
					draw_set_text(f_p0, fa_left, fa_top, c_white);
					line = string_copy(line, sp + 1, string_length(line) - sp);
					draw_sprite_ext(s_text_bullet, 0, xx + 16, _y + yy + 10, 1, 1, 0, c_ui_blue_grey, 1);
					draw_text_ext(xx + 28, _y + yy, line, -1, ww);
					break;
				case "+" :
					draw_set_text(f_p0, fa_left, fa_top, c_white);
					line = string_copy(line, sp + 1, string_length(line) - sp);
					draw_sprite_ext(s_text_bullet, 1, xx + 16, _y + yy + 10, 1, 1, 0, $5dde8f, 1);
					draw_text_ext(xx + 28, _y + yy, line, -1, ww);
					break;
				default :
					draw_set_text(f_p0, fa_left, fa_top, c_white);
					draw_text_ext(xx + 0, _y + yy, line, -1, ww);
					break;
			}
			
			yy += string_height_ext(line, -1, ww);
		}
		
		return yy + 64;
	})
#endregion