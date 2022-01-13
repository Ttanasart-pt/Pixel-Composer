function checkBox(_onClick) constructor {
	active = false;
	hover  = false;
	
	onClick = _onClick;
	
	function draw(_x, _y, _value, _m) {
		var cx = _x;
		var cy = _y;
		
		draw_sprite_stretched(s_checkbox, _value * 2, cx, cy, 28, 28);	
		
		if(hover && point_in_rectangle(_m[0], _m[1], cx, cy, cx + 28, cy + 28)) {
			draw_sprite_stretched(s_checkbox, _value * 2 + 1, _x, _y, 28, 28);	
			
			if(active && mouse_check_button_pressed(mb_left)) {
				if(onClick) onClick();
			}
		}
		
		hover  = false;
		active = false;
	}
}
