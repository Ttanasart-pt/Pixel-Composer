function checkBox(_onClick) : widget() constructor {
	onClick = _onClick;
	
	static trigger = function() { 
		if(!onClick) return;
		onClick();
	}
	
	static draw = function(_x, _y, _value, _m, ss = ui(28), halign = fa_left, valign = fa_top) {
		x = _x;
		y = _y;
		w = ss;
		h = ss;
		
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
				trigger();
		} else
			if(mouse_press(mb_left)) deactivate();
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched(THEME.widget_selecting, 0, _dx - ui(3), _dy - ui(3), ss + ui(6), ss + ui(6));	
		
		resetFocus();
	}
}
