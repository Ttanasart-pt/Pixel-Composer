function checkBoxGroup(_sprs, _onClick) : widget() constructor {
	sprs    = _sprs;
	size    = sprite_get_number(sprs);
	onClick = _onClick;
	
	holding   = noone;
	tooltips  = [];
	
	static trigger     = function(v,i) /*=>*/ { onClick(v, i); return self; }
	static setTooltips = function(tt)  /*=>*/ { tooltips = tt; return self; } 
	
	static fetchHeight = function(params) { return params.s; }
	static drawParam = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _h, _value, _m, halign = fa_left, valign = fa_top) {
		x = _x;
		y = _y;
		w = _h * size;
		h = _h;
		
		if(mouse_release(mb_left))
			holding = noone;
		
		var aa = interactable * 0.25 + 0.75;
		for( var i = 0; i < size; i++ ) {
			var spr = i == 0 ? THEME.button_left : (i == size - 1? THEME.button_right : THEME.button_middle);
			var ind = _value[i] * 2;
				
			if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _h, _y + _h)) {			
				ind = 1
				TOOLTIP = array_safe_get(tooltips, i, "");
				
				if(holding != noone)
					trigger(holding, i);
				
				if(mouse_press(mb_left, active)) {
					trigger(!_value[i], i);
					holding = _value[i];
				}
			} else
				if(mouse_press(mb_left)) deactivate();
			
			draw_sprite_stretched_ext(spr, ind, _x, _y, _h, _h, c_white, aa);
			if(_value[i]) draw_sprite_stretched_ext(spr, 3, _x, _y, _h, _h, COLORS._main_accent, 1);
			draw_sprite_ui(sprs, i, _x + _h / 2, _y + _h / 2, 1, 1, 0, c_white, 0.5 + _value[i] * 0.5);
			
			_x += _h;
		}
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, _x - ui(3), _y - ui(3), _h + ui(6), _h + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() /*=>*/ {return new checkBoxGroup(sprs, onClick)};
}
