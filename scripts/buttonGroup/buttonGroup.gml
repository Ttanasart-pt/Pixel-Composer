function buttonGroup(_data, _onClick) : widget() constructor {
	data    = _data;
	onClick = _onClick;
	size    = array_length(data);
	
	display_button = false;
	buttonSpr      = [ THEME.button_left, THEME.button_middle, THEME.button_right ];
	fColor         = COLORS._main_text;
	
	tooltips  = [];
	
	current_selecting = 0;
	collapsable = true;
	
	for(var i = 0; i < array_length(data); i++) 
		buttons[i] = button(-1);
	
	sb_small = new scrollBox(data, _onClick);
	
	static setFont = function(font) {
		self.font = font;
		return self;
	}
	
	static setTooltips = function(tt) { tooltips = tt;    return self; } 
	static setCollape  = function(cc) { collapsable = cc; return self; } 
	
	static trigger = function() {
		if(current_selecting + 1 >= array_length(data))
			onClick(0);
		else
			onClick(current_selecting + 1);
	}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		for(var i = 0; i < array_length(data); i++) 
			buttons[i].interactable = interactable;
		sb_small.interactable = interactable;
	}
	
	static register = function(parent = noone) { 
		if(display_button) {
			array_push(WIDGET_ACTIVE, self); 
			self.parent = parent;
		} else
			sb_small.register(parent);
	}
	
	static drawParam = function(params) {
		setParam(params);
		sb_small.setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m, params.rx, params.ry);
	}
	
	static draw = function(_x, _y, _w, _h, _selecting, _m, _rx = 0, _ry = 0) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		current_selecting = _selecting;
		while(is_array(current_selecting))
			current_selecting = array_safe_get_fast(current_selecting, 0);
		hovering = hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		
		var amo  = array_length(data);
		var _tw  = _w;
		var _mx  = false, _t = 0;
		var _sw  = _h + ui(8);
		var tamo = amo;
		
		var total_width = 0;
		draw_set_font(font);
		for(var i = 0; i < amo; i++) {
			var _d = data[i];
			
		    if(is_string(_d)) {
		    	_t = 1;
		    	total_width += ui(32) + string_width(_d);
		    	
			} else if(sprite_exists(_d)) {
				if(_t) _mx = true;
				if(_mx) tamo--;
				
				total_width += _sw;
				_tw -= _sw;
			}
		}
		
		display_button = !collapsable || total_width < _w;
		var ww  = (_mx? _tw : _w) / tamo;
		
		if(display_button) {
			var bx = _x;
			var draw_sel = noone;
			
			for(var i = 0; i < amo; i++) {
				var _d = data[i];
				
				buttons[i].setFocusHover(active, hover);
				buttons[i].tooltip = array_safe_get(tooltips, i, "");
				
				var bww = !is_string(_d) && sprite_exists(_d) && _mx? _sw : ww;
				var spr = i == 0 ? buttonSpr[0] : (i == amo - 1? buttonSpr[2] : buttonSpr[1]);
				
				if(_selecting == i) {
					draw_sprite_stretched(spr, 2, floor(bx), _y, ceil(bww), _h);
					draw_sel = [spr, bx];
				} else {
					buttons[i].draw(floor(bx), _y, ceil(bww), _h, _m, spr);
					if(buttons[i].clicked) onClick(i);
				}
				
				if(is_string(data[i])) {
					draw_set_text(font, fa_center, fa_center, fColor);
					draw_text_add(bx + bww / 2, _y + _h / 2, data[i]);
					
				} else if(sprite_exists(data[i])) {
					draw_sprite_ui_uniform(data[i], i, bx + bww / 2, _y + _h / 2, 1);
					
				}
				
				bx += bww;
			}
			
			if(draw_sel != noone)
				draw_sprite_stretched_ext(draw_sel[0], 3, draw_sel[1], _y, ww, _h, COLORS._main_accent, 1);	
			
			if(point_in_rectangle(_m[0], _m[1], _x, _y, _x + w, _y + _h)) {
				if(is_array(data) && key_mod_press(SHIFT)) {
					var len = array_length(data);
					if(len) {
						if(mouse_wheel_down())	onClick(safe_mod(_selecting + 1 + len, len));
						if(mouse_wheel_up())	onClick(safe_mod(_selecting - 1 + len, len));
					}
				}
			}
		} else {
			sb_small.setFocusHover(active, hover);
			sb_small.draw(_x, _y, _w, _h, array_safe_get(data, _selecting, "-"), _m, _rx, _ry);
		}
		
		if(WIDGET_CURRENT == self)
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, x - ui(3), y - ui(3), w + ui(6), h + ui(6), COLORS._main_accent, 1);	
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() { #region
		var cln = new buttonGroup(data, onClick);
		return cln;
	} #endregion
}