function draw_text_path(_x, _y, _text) {
	draw_set_text(font == noone? f_p0 : font, fa_left, fa_top, color);
	var _x0 = _x, ch = "", len = string_length(_text), i = 1;
	var cc  = draw_get_color();
	var str = "", _comm = false;
				
	while(i <= len) {
		ch = string_char_at(_text, i);
					
		if(ch == "%")
			_comm = true;
					
		if(!_comm) {
			draw_text_add(_x0, _y, ch);
			_x0 += string_width(ch);
		} else {
			str += ch;
			switch(ch) {
				case "d" : draw_set_color(COLORS.widget_text_dec_d); break;	
				case "n" : draw_set_color(COLORS.widget_text_dec_n); break;	
				case "e" : draw_set_color(COLORS.widget_text_dec_e); break;	
				case "f" : draw_set_color(COLORS.widget_text_dec_f); break;	
				case "i" : draw_set_color(COLORS.widget_text_dec_i); break;
			}
						
			switch(ch) {
				case "d" :	case "n" :	case "e" :	case "f" :	case "i" : 
					draw_text_add(_x0, _y, str);
					_x0 += string_width(str);
					_comm = false; 
					str = "";
								
					draw_set_color(cc);
					break;
			}
		}
					
		i++;
	}
				
	draw_text_add(_x0, _y, str);
}