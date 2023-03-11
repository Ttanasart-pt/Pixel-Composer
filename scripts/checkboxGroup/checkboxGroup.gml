function checkBoxGroup(sprs, _onClick) : widget() constructor {
	self.sprs = sprs;
	self.size = sprite_get_number(sprs);
	onClick   = _onClick;
	
	holding   = noone;
	
	static trigger = function(ind, val) { 
		onClick(ind, val);
	}
	
	static draw = function(_x, _y, _value, _m, ss = ui(28), halign = fa_left, valign = fa_top) {
		x = _x;
		y = _y;
		w = ss * size;
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
		
		if(mouse_release(mb_left))
			holding = noone;
		
		var aa = interactable * 0.25 + 0.75;
		for( var i = 0; i < size; i++ ) {
			var spr = i == 0 ? THEME.button_left : (i == size - 1? THEME.button_right : THEME.button_middle);
			draw_sprite_stretched_ext(spr, _value[i] * 2, _dx, _dy, ss, ss, c_white, aa);
			
			if(hover && point_in_rectangle(_m[0], _m[1], _dx, _dy, _dx + ss, _dy + ss)) {			
				if(holding != noone)
					trigger(i, holding);
				
				if(mouse_press(mb_left, active)) {
					trigger(i, !_value[i]);
					holding = _value[i];
				}
			} else
				if(mouse_press(mb_left)) deactivate();
			draw_sprite_stretched_ext(sprs, i, _dx, _dy, ss, ss, c_white, 0.5 + _value[i] * 0.5);
			
			_dx += ss;
		}
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched(THEME.widget_selecting, 0, _dx - ui(3), _dy - ui(3), ss + ui(6), ss + ui(6));	
		
		resetFocus();
	}
}
