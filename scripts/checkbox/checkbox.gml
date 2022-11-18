function checkBox(_onClick) constructor {
	active = false;
	hover  = false;
	
	onClick = _onClick;
	
	static draw = function(_x, _y, _value, _m, ss = ui(28), halign = fa_left, valign = fa_top) {
		switch(halign) {
			case fa_left:   _x = _x;			break;	
			case fa_center: _x = _x - ss / 2;	break;	
			case fa_right:  _x = _x - ss;		break;	
		}
		
		switch(valign) {
			case fa_top:    _y = _y;			break;	
			case fa_center: _y = _y - ss / 2;	break;	
			case fa_bottom: _y = _y - ss;		break;	
		}
		
		draw_sprite_stretched(THEME.checkbox, _value * 2, _x, _y, ss, ss);	
		
		if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ss, _y + ss)) {
			draw_sprite_stretched(THEME.checkbox, _value * 2 + 1, _x, _y, ss, ss);	
			
			if(active && mouse_check_button_pressed(mb_left)) {
				if(onClick) onClick();
			}
		}
		
		hover  = false;
		active = false;
	}
}
