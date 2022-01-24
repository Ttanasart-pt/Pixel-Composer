function buttonGradient(_onApply) {
	return new buttonGradientClass(_onApply);
}

function buttonGradientClass(_onApply) constructor {
	active = false;
	hover  = false;
	
	onApply = _onApply;
	
	static draw = function(_x, _y, _w, _h, _gradient, _data, _m) {
		var click = false;
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			draw_sprite_stretched(s_button, 1, _x, _y, _w, _h);	
			if(active && mouse_check_button_pressed(mb_left)) {
				var dialog = dialogCall(o_dialog_gradient, WIN_W / 2, WIN_H / 2);
				dialog.setGradient(_gradient, _data);
				dialog.onApply = onApply;
				click = true;
			}
			if(mouse_check_button(mb_left))
				draw_sprite_stretched(s_button, 2, _x, _y, _w, _h);	
		} else {
			draw_sprite_stretched(s_button, 0, _x, _y, _w, _h);		
		}
		
		draw_gradient(_x + 6, _y + 6, _w - 12, _h - 12, _gradient, _data[| 0]);
		
		hover  = false;
		active = false;
		
		return click;
	}
}