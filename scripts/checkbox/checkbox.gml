function checkBox(_onClick) constructor {
	active = false;
	hover  = false;
	
	onClick = _onClick;
	
	static draw = function(_x, _y, _value, _m, _s = 28) {
		var cx = _x;
		var cy = _y;
		
		draw_sprite_stretched(s_checkbox, _value * 2, cx, cy, _s, _s);	
		
		if(hover && point_in_rectangle(_m[0], _m[1], cx, cy, cx + _s, cy + _s)) {
			draw_sprite_stretched(s_checkbox, _value * 2 + 1, _x, _y, _s, _s);	
			
			if(active && mouse_check_button_pressed(mb_left)) {
				if(onClick) onClick();
			}
		}
		
		hover  = false;
		active = false;
	}
}
