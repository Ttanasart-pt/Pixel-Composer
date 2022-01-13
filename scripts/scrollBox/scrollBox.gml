function scrollBox(_data, _onModify) constructor {
	onModify  = _onModify;	
	data_list = _data;
	
	active = false;
	hover  = false;
	open   = false;
	
	function draw(_x, _y, _w, _h, _text, _m, _rx, _ry) {
		if(!open) {
			if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
				draw_sprite_stretched(s_textbox, 1, _x, _y, _w, _h);
				if(active && mouse_check_button_pressed(mb_left)) {
					open = true;
					with(dialogCall(o_dialog_scrollbox, _x + _rx, _y + _ry)) {
						scrollbox = other;	
						dialog_w  = _w;
					}
				}
				if(mouse_check_button(mb_left))
					draw_sprite_stretched(s_textbox, 2, _x, _y, _w, _h);	
			} else {
				draw_sprite_stretched(s_textbox, 0, _x, _y, _w, _h);		
			}
		
			draw_set_text(f_p0, fa_center, fa_center, c_white);
			draw_text(_x + _w / 2, _y + _h / 2, _text);
			draw_sprite(s_scroll_box_arrow, 0, _x + _w - 20, _y + _h / 2);
		}
		
		hover  = false;
		active = false;
	}
}