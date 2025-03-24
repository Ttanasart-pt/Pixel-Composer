function vectorRangeBox(_size, _type, _onModify, _unit = noone) : widget() constructor {
	size     = _size;
	type     = _type;
	onModify = _onModify;
	unit	 = _unit;
	
	linked   = false;
	ranged   = false;
	
	disp_h = 0;
	
	tooltip_ranged = new tooltipSelector("Value Type", [ __txtx("widget_range_constant", "Constant"), __txtx("widget_range_random", "Random Range") ]);
	
	onModifyIndex = function(val, index) { 
		var v = toNumber(val);
		
		if(!linked && ranged) return onModify(v, index);
		var modi = false;
		
		if(linked && !ranged) {
			modi |= onModify(v, 0);
			modi |= onModify(v, 1);
			modi |= onModify(v, 2);
			modi |= onModify(v, 3);
			
		} else if(linked) {
			modi |= onModify(v,  index);
			modi |= onModify(v, (index + 2) % 4);
			
		} else if(!ranged) {
			modi |= onModify(v, floor(index / 2) * 2 + 0);
			modi |= onModify(v, floor(index / 2) * 2 + 1);
			
		}
		
		return modi;
	}
	
	axis = [ "x", "y", "z", "w"];
	onModifySingle[0] = function(val) { return onModifyIndex(val, 0); }
	onModifySingle[1] = function(val) { return onModifyIndex(val, 1); }
	onModifySingle[2] = function(val) { return onModifyIndex(val, 2); }
	onModifySingle[3] = function(val) { return onModifyIndex(val, 3); }
	
	extras = -1;
	
	for(var i = 0; i < size; i++) {
		tb[i] = new textBox(_type, onModifySingle[i]);
		tb[i].slidable = true;
		tb[i].hide     = true;
	}
	
	static setInteract = function(interactable = noone) {
		self.interactable = interactable;
		for( var i = 0; i < size; i++ ) tb[i].interactable = interactable;
	}
	
	static register = function(parent = noone) { for( var i = 0; i < size; i++ ) tb[i].register(parent); }
	
	static isHovering = function() { 
		for( var i = 0, n = array_length(tb); i < n; i++ ) if(tb[i].isHovering()) return true;
		return false;
	}
	
	static drawParam = function(params) {
		setParam(params);
		for(var i = 0; i < size; i++) tb[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _display_data, _m) {
		x = _x;
		y = _y;
		w = _w;
		
		_data = array_verify(_data, size);
		
		if(struct_has(_display_data, "linked")) linked = _display_data.linked;
		if(struct_has(_display_data, "ranged")) ranged = _display_data.ranged;
		
		h = _h * 2 + ui(4);
		
		var _bs = min(_h, ui(32));
		
		if((_w - _bs) / 2 > ui(64)) {
			if(side_button) {
				side_button.setFocusHover(active, hover);
				side_button.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide_fill);
				_w -= _bs + ui(4);
			}
			
			var bx = _x;
			var by = _y + _h / 2 - _bs / 2;
			var bc = linked? COLORS._main_accent : COLORS._main_icon;
			
			if(buttonInstant(THEME.button_hide_fill, bx, by, _bs, _bs, _m, hover, active, __txt("Link axis"), THEME.value_link, linked, bc) == 2) {
				linked = !linked;
				_display_data.linked = linked;
			
				if(linked) {
					onModifyIndex(_data[0], 0);
					onModifyIndex(_data[1], 1);
				}
			}
			
			by += _h + ui(4);
			
			tooltip_ranged.index = ranged;
			var b  = buttonInstant(THEME.button_hide_fill, bx, by, _bs, _bs, _m, hover, active, tooltip_ranged, THEME.value_range, ranged, COLORS._main_icon);
			var tg = false;
			if(b == 1 && key_mod_press(SHIFT) && MOUSE_WHEEL != 0) tg = true;
			if(b == 2) tg = true;
			
			if(tg) {
				ranged = !ranged;
				_display_data.ranged = ranged;
			
				if(!ranged) {
					onModifyIndex(_data[0], 0);
					onModifyIndex(_data[1], 2);
				}
			}
			
			_x += _bs + ui(4);
			_w -= _bs + ui(4);
		}
		
		var ww = _w / 2;
		
		for( var j = 0; j < 2; j++ ) {
			var by = _y + (_h + ui(4)) * j;
			
			draw_sprite_stretched_ext(THEME.textbox, 3, _x, by, _w, _h, boxColor, 1);
			draw_sprite_stretched_ext(THEME.textbox, 0, _x, by, _w, _h, boxColor, 0.5 + 0.5 * interactable);	
		}
		
		if(linked) {
			draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, _x      + ww / 2 - ui(2), _y + _h / 2, ui(4), _h + ui(4), COLORS._main_accent, .2);
			draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, _x + ww + ww / 2 - ui(2), _y + _h / 2, ui(4), _h + ui(4), COLORS._main_accent, .2);
		}
		
		if(!ranged) {
			draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, _x + ww / 2, _y +              _h / 2 - ui(2), ww, ui(4), COLORS._main_accent, .2);
			draw_sprite_stretched_ext(THEME.ui_scrollbar, 0, _x + ww / 2, _y + _h + ui(4) + _h / 2 - ui(2), ww, ui(4), COLORS._main_accent, .2);
		}
		
		for( var j = 0; j < 2; j++ ) {
			var by = _y + (_h + ui(4)) * j;
			
			for( var i = 0; i < 2; i++ ) {
				var bx = _x + ww * i;
				
				if(i == 0) tb[j * 2 + i].label = axis[j];
				tb[j * 2 + i].setFocusHover(active, hover);
				tb[j * 2 + i].draw(bx, by, ww, _h, _data[j * 2 + i], _m);
			}
		}
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() {
		var cln = new vectorRangeBox(size, type, onModify, unit);
		
		cln.axis   = axis;
		cln.extras = extras;
		
		return cln;
	}
	
	static free = function() {
		for( var i = 0, n = array_length(tb); i < n; i++ ) tb[i].free();
	}
}