function draw_text_delimiter(ch_x, ch_y, _str) {
	var _x = ch_x;
	var _y = ch_y;
	var cc = draw_get_color();
	
	for( var i = 1; i <= string_length(_str); i++ ) {
		var ch = string_char_at(_str, i);
		
		if(ch == " ") {
			ch = "<space>";
			draw_set_color(COLORS._main_text_sub);
		} else
			draw_set_color(cc);
		
		draw_text(_x, _y, ch);
		_x += string_width(ch);
	}
}