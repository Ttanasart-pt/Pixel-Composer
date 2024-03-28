function toggleGroup(_data, _onClick) : widget() constructor {
	data    = _data;
	onClick = _onClick;
	buttonSpr = [ THEME.button_left, THEME.button_middle, THEME.button_right ];
	font	= f_p0;
	fColor  = COLORS._main_text;
	value   = 0;
	
	for(var i = 0; i < array_length(data); i++) 
		buttons[i] = button(-1);
	
	static trigger = function() {}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		for(var i = 0; i < array_length(data); i++) 
			buttons[i].interactable = interactable;
	}
	
	static register = function(parent = noone) { 
		array_push(WIDGET_ACTIVE, self); 
		self.parent = parent;
	}
	
	static isHovering = function() { 
		for( var i = 0, n = array_length(buttons); i < n; i++ ) if(buttons[i].isHovering()) return true;
		return false;
	}
	
	static drawParam = function(params) {
		setParam(params);
		for(var i = 0; i < array_length(data); i++) 
			buttons[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m, params.rx, params.ry);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m, _rx = 0, _ry = 0) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		value = _data;
		
		if(is_array(_data)) return 0;
		
		var amo = array_length(data);
		var ww  = _w / amo;
		
		for(var i = 0; i < amo; i++) {
			buttons[i].setFocusHover(active, hover);
			
			var bx  = _x + ww * i;
			var spr = i == 0 ? buttonSpr[0] : (i == amo - 1? buttonSpr[2] : buttonSpr[1]);
			var tog = _data & (1 << i);
			
			buttons[i].toggled = tog;
			buttons[i].draw(bx, _y, ww, _h, _m, spr);
			
			if(buttons[i].clicked) {
				value ^= (1 << i);
				onClick(value);
			}
				
			if(is_string(data[i])) {
				draw_set_text(font, fa_center, fa_center, fColor);
				draw_text(bx + ww / 2, _y + _h / 2, data[i]);
			} else if(sprite_exists(data[i])) {
				draw_sprite_ui_uniform(data[i], i, bx + ww / 2, _y + _h / 2);
			}
		}
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, x - ui(3), y - ui(3), w + ui(6), h + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
		
		return h;
	}
}