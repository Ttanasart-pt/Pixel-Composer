function rangeBox(_type, _onModify) : widget() constructor {
	type     = _type;
	onModify = _onModify;
	linked   = false;
	
	disp_w = 0;
	
	tooltip	= new tooltipSelector("Value Type", [
		__txtx("widget_range_random",   "Random Range"),
		__txtx("widget_range_constant", "Constant"),
	]);
	
	onModifyIndex = function(val, index) { 
		var modi = false;
		
		if(linked) {
			for( var i = 0; i < 2; i++ )
				modi |= onModify(toNumber(val), i); 
			return modi;
		}
		
		return onModify(toNumber(val), index); 
	}
	
	labels = [ "min", "max" ];
	onModifySingle[0] = function(v) /*=>*/ {return onModifyIndex(toNumber(v), 0)};
	onModifySingle[1] = function(v) /*=>*/ {return onModifyIndex(toNumber(v), 1)};
	
	extras = -1;
	
	for(var i = 0; i < 2; i++) {
		tb[i] = new textBox(_type, onModifySingle[i])
		           .setHide(true)
		           .setLabel(labels[i]);
	}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		
		tb[0].interactable = interactable;
		if(!linked) tb[1].interactable = interactable;
	} 
	
	static register = function(parent = noone) { 
		tb[0].register(parent);
		if(!linked) tb[1].register(parent);
	} 
	
	static isHovering = function() { 
		for( var i = 0, n = array_length(tb); i < n; i++ ) if(tb[i].isHovering()) return true;
		return false;
	} 
	
	static drawParam = function(params) { 
		setParam(params);
		for(var i = 0; i < 2; i++) tb[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m);
	} 
	
	static draw = function(_x, _y, _w, _h, _data, _display_data, _m) { 
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		linked = _display_data[$ "linked"] ?? linked;
		tooltip.index = linked;
		
		var _icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
		var _bs = min(_h, ui(32));
		
		if((_w - _bs) / 2 > ui(64)) {
			if(side_button) {
				side_button.setFocusHover(active, hover);
				side_button.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide_fill);
				_w -= _bs + ui(4);
			}
			
			var bx = _x;
			var by = _y + _h / 2 - _bs / 2;
			var b  = buttonInstant(THEME.button_hide_fill, bx, by, _bs, _bs, _m, hover, active, tooltip, THEME.value_link, linked, _icon_blend);
			var tg = false;
			
			if(b == 1) {
				if(key_mod_press(SHIFT) && mouse_wheel_up())   tg = true;
				if(key_mod_press(SHIFT) && mouse_wheel_down()) tg = true;
			} 
			if(b == 2) tg = true;
			
			if(tg) {
				linked = !linked;
				_display_data.linked = linked;
			
				if(linked) {
					onModify(_data[0], 0);
					onModify(_data[0], 1);
				}
			}
		
			_x += _bs + ui(4);
			_w -= _bs + ui(4);
		}
		
		var ww = linked? _w : _w / 2;
		disp_w = disp_w == 0? ww : lerp_float(disp_w, ww, 5);
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, _h, boxColor, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, boxColor, 0.5 + 0.5 * interactable);	
			
		if(linked) {
			tb[0].setFocusHover(active, hover);
			tb[0].draw(_x, _y, disp_w, _h, _data[0], _m);
			tb[0].setLabel("value");
			
		} else if(is_array(_data) && array_length(_data) >= 2) {
			for(var i = 0; i < 2; i++) {
				tb[i].setFocusHover(active, hover);
				tb[i].setLabel(labels[i]);
				
				var bx  = _x + disp_w * i;
				tb[i].draw(bx, _y, disp_w, _h, _data[i], _m);
			}
		}
		
		resetFocus();
		
		return h;
	} 
	
	static clone = function() { 
		var cln = new rangeBox(type, onModify);
		
		return cln;
	} 

	static free = function() {
		for( var i = 0, n = array_length(tb); i < n; i++ ) tb[i].free();
	}
}