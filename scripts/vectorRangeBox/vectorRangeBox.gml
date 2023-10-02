function vectorRangeBox(_size, _type, _onModify, _unit = noone) : widget() constructor {
	size     = _size;
	onModify = _onModify;
	unit	 = _unit;
	linked   = false;
	
	tooltip	= new tooltipSelector("Value Type", [
		__txtx("widget_range_random",   "Random Range"),
		__txtx("widget_range_constant", "Constant"),
	]);
	
	onModifyIndex = function(index, val) { 
		if(linked) {
			var modi = false;
			modi |= onModify(floor(index / 2) * 2 + 0, toNumber(val)); 
			modi |= onModify(floor(index / 2) * 2 + 1, toNumber(val)); 
			return modi;
		}
		
		return onModify(index, toNumber(val)); 
	}
	
	axis = [ "x", "y", "z", "w"];
	onModifySingle[0] = function(val) { return onModifyIndex(0, toNumber(val)); }
	onModifySingle[1] = function(val) { return onModifyIndex(1, toNumber(val)); }
	onModifySingle[2] = function(val) { return onModifyIndex(2, toNumber(val)); }
	onModifySingle[3] = function(val) { return onModifyIndex(3, toNumber(val)); }
	
	extras = -1;
	
	for(var i = 0; i < size; i++) {
		tb[i] = new textBox(_type, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	static setSlideSpeed = function(speed) {
		for(var i = 0; i < size; i++)
			tb[i].slide_speed = speed;
	}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		
		var _step = linked? 2 : 1;
		for( var i = 0; i < size; i += _step ) 
			tb[i].interactable = interactable;
	}
	
	static register = function(parent = noone) {
		var _step = linked? 2 : 1;
		for( var i = 0; i < size; i += _step ) 
			tb[i].register(parent);
	}
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _display_data, _m) {
		x = _x;
		y = _y;
		w = _w;
		
		if(struct_has(_display_data, "linked")) linked = _display_data.linked;
		h = linked? _h : _h * 2 + ui(4);
		tooltip.index = linked;
		
		var _icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
		
		var bx = _x;
		var by = _y + _h / 2 - ui(32 / 2);
		if(buttonInstant(THEME.button_hide, bx + ui(4), by + ui(4), ui(24), ui(24), _m, active, hover, tooltip, THEME.value_link, linked, _icon_blend) == 2) {
			linked = !linked;
			_display_data.linked =  linked;
			
			if(linked) {
				for(var i = 0; i < size; i += 2) {
					onModify(i + 0, _data[i]);
					onModify(i + 1, _data[i]);
				}
			}
		}
		
		_x += ui(28);
		_w -= ui(28);
		
		var _step = linked? 2 : 1;
		var ww    = _w / size * 2;
		
		for(var i = 0; i < size; i += _step) {
			tb[i].setFocusHover(active, hover);
			
			var bx  = _x + ww * floor(i / 2);
			var by  = _y + i % 2 * (_h + ui(4));
			var _ww = ui(32 + 32 * !linked);
			tb[i].draw(bx + _ww, by, ww - _ww, _h, _data[i], _m);
			
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_inner);
			
			var _label = linked? axis[floor(i / 2)]
				: (i % 2? __txt("Max") : __txt("Min")) + " " + axis[floor(i / 2)];
			draw_text(bx + ui(8), by + _h / 2, _label);
		}
		
		resetFocus();
		
		return h;
	}
}