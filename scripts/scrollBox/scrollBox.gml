function scrollBox(_data, _onModify) constructor {
	onModify  = _onModify;	
	data_list = _data;
	data = [];
	
	active = false;
	hover  = false;
	open   = false;
	
	align = fa_center;
	extra_button = noone;
	
	static draw = function(_x, _y, _w, _h, _text, _m = mouse_ui, _rx = 0, _ry = 0) {
		var ww = _w;
		if(extra_button != noone) {
			extra_button.hover  = hover;
			extra_button.active = active;
			extra_button.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
			ww -= ui(40);
		}
		
		if(open) {
			hover  = false;
			active = false;
			return;
		}
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + _h)) {
			draw_sprite_stretched(THEME.textbox, 1, _x, _y, ww, _h);
			if(mouse_press(mb_left, active)) {
				if(is_method(data_list))
					data = data_list();
				else 
					data = data_list;
					
				open = true;
				with(dialogCall(o_dialog_scrollbox, _x + _rx, _y + _ry)) {
					scrollbox = other;	
					dialog_w  = ww;
					align = other.align;
				}
			}
			if(mouse_click(mb_left, active))
				draw_sprite_stretched(THEME.textbox, 2, _x, _y, ww, _h);	
		} else {
			draw_sprite_stretched(THEME.textbox, 0, _x, _y, ww, _h);		
		}
		
		draw_set_text(f_p0, align, fa_center, COLORS._main_text);
		if(align == fa_center)
			draw_text(_x + ww / 2, _y + _h / 2 - ui(2), _text);
		else if(align == fa_left)
			draw_text(_x + ui(8), _y + _h / 2 - ui(2), _text);
		draw_sprite_ui_uniform(THEME.scroll_box_arrow, 0, _x + ww - 20, _y + _h / 2, 1, COLORS._main_icon);
		
		hover  = false;
		active = false;
	}
}