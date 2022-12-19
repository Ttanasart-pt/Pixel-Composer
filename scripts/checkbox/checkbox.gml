function checkBox(_onClick) constructor {
	active = false;
	hover  = false;
	
	onClick = _onClick;
	
	static draw = function(_x, _y, _value, _m, ss = ui(28), halign = fa_left, valign = fa_top) {
		var _dx, _dy;
		switch(halign) {
			case fa_left:   _dx = _x;			break;	
			case fa_center: _dx = _x - ss / 2;	break;	
			case fa_right:  _dx = _x - ss;		break;	
		}
		
		switch(valign) {
			case fa_top:    _dy = _y;			break;	
			case fa_center: _dy = _y - ss / 2;	break;	
			case fa_bottom: _dy = _y - ss;		break;	
		}
		
		draw_sprite_stretched(THEME.checkbox, _value * 2, _dx, _dy, ss, ss);	
		
		if(hover && point_in_rectangle(_m[0], _m[1], _dx, _dy, _dx + ss, _dy + ss)) {
			draw_sprite_stretched(THEME.checkbox, _value * 2 + 1, _dx, _dy, ss, ss);	
			
			if(mouse_press(mb_left, active))
				if(onClick) onClick();
		}
		
		hover  = false;
		active = false;
	}
}
