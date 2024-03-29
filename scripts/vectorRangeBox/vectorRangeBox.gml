function vectorRangeBox(_size, _type, _onModify, _unit = noone) : widget() constructor {
	size     = _size;
	onModify = _onModify;
	unit	 = _unit;
	linked   = false;
	
	disp_h = 0;
	
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
	
	for(var i = 0; i < size; i++) { #region
		tb[i] = new textBox(_type, onModifySingle[i]);
		tb[i].slidable = true;
		tb[i].hide     = true;
	} #endregion
	
	static setSlideSpeed = function(speed) { #region
		for(var i = 0; i < size; i++)
			tb[i].setSlidable(speed);
	} #endregion
	
	static setInteract = function(interactable = noone) { #region
		self.interactable = interactable;
		
		var _step = linked? 2 : 1;
		for( var i = 0; i < size; i += _step ) 
			tb[i].interactable = interactable;
	} #endregion
	
	static register = function(parent = noone) { #region
		var _step = linked? 2 : 1;
		for( var i = 0; i < size; i += _step ) 
			tb[i].register(parent);
	} #endregion
	
	static isHovering = function() { 
		for( var i = 0, n = array_length(tb); i < n; i++ ) if(tb[i].isHovering()) return true;
		return false;
	}
	
	static drawParam = function(params) { #region
		setParam(params);
		for(var i = 0; i < size; i++) tb[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m);
	} #endregion
	
	static draw = function(_x, _y, _w, _h, _data, _display_data, _m) { #region
		x = _x;
		y = _y;
		w = _w;
		
		if(struct_has(_display_data, "linked")) linked = _display_data.linked;
		var _hh = linked? _h : _h * 2 + ui(4);
		h = h == 0? _hh : lerp_float(h, _hh, 5);
		tooltip.index = linked;
		
		var _icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
		
		var _bs = min(_h, ui(32));
		if((_w - _bs) / 2 > ui(64)) {
			var bx  = _x;
			var by  = _y + _h / 2 - _bs / 2;
		
			if(buttonInstant(THEME.button_hide, bx, by, _bs, _bs, _m, active, hover, tooltip, THEME.value_link, linked, _icon_blend) == 2) {
				linked = !linked;
				_display_data.linked = linked;
			
				if(linked) {
					for(var i = 0; i < size; i += 2) {
						onModify(i + 0, _data[i]);
						onModify(i + 1, _data[i]);
					}
				}
			}
		
			_x += _bs + ui(4);
			_w -= _bs + ui(4);
		}
		
		var ww = _w / 2;
		
		if(linked) {
			draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, _h, c_white, 1);
			draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, c_white, 0.5 + 0.5 * interactable);	
		
			for( var i = 0; i < 2; i++ ) {
				var bx = _x + ww * i;
				var by = _y;
				
				tb[i * 2].label = axis[i];
				tb[i * 2].setFocusHover(active, hover);
				tb[i * 2].draw(bx, by, ww, _h, _data[i * 2], _m);
			}
		} else {
			for( var j = 0; j < 2; j++ ) {
				var by = _y + (_h + ui(4)) * j;
				
				draw_sprite_stretched_ext(THEME.textbox, 3, _x, by, _w, _h, c_white, 1);
				draw_sprite_stretched_ext(THEME.textbox, 0, _x, by, _w, _h, c_white, 0.5 + 0.5 * interactable);	
			
				for( var i = 0; i < 2; i++ ) {
					var bx = _x + ww * i;
					
					if(i == 0) tb[j * 2 + i].label = axis[j];
					tb[j * 2 + i].setFocusHover(active, hover);
					tb[j * 2 + i].draw(bx, by, ww, _h, _data[j * 2 + i], _m);
				}
			}
		}
		
		resetFocus();
		
		return h;
	} #endregion
}