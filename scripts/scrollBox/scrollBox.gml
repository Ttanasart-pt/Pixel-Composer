function scrollBox(_data, _onModify) constructor {
	onModify  = _onModify;	
	data_list = _data;
	
	active = false;
	hover  = false;
	open   = false;
	
	align = fa_center;
	
	static draw = function(_x, _y, _w, _h, _text, _m, _rx, _ry) {
		if(!open) {
			if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
				draw_sprite_stretched(s_textbox, 1, _x, _y, _w, _h);
				if(active && mouse_check_button_pressed(mb_left)) {
					open = true;
					with(dialogCall(o_dialog_scrollbox, _x + _rx, _y + _ry)) {
						scrollbox = other;	
						dialog_w  = _w;
						align = other.align;
					}
				}
				if(mouse_check_button(mb_left))
					draw_sprite_stretched(s_textbox, 2, _x, _y, _w, _h);	
			} else {
				draw_sprite_stretched(s_textbox, 0, _x, _y, _w, _h);		
			}
		
			draw_set_text(f_p0, align, fa_center, c_white);
			if(align == fa_center)
				draw_text(_x + _w / 2, _y + _h / 2 - ui(2), _text);
			else if(align == fa_left)
				draw_text(_x + ui(8), _y + _h / 2 - ui(2), _text);
			draw_sprite_ui_uniform(s_scroll_box_arrow, 0, _x + _w - 20, _y + _h / 2, 1, c_ui_blue_grey);
		}
		
		hover  = false;
		active = false;
	}
}