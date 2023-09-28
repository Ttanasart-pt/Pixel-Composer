function matrixGrid(_type, _size, _onModify, _unit = noone) : widget() constructor {
	size	 = _size;
	inputs   = size * size;
	onModify = _onModify;
	unit	 = _unit;
	
	linked = false;
	b_link = button(function() { linked = !linked; });
	b_link.icon = THEME.value_link;
	
	onModifyIndex = function(index, val) { 
		var modi = false;
		
		if(linked) {
			for( var i = 0; i < inputs; i++ )
				modi |= onModify(i, toNumber(val)); 
			return modi;
		}
		
		return onModify(index, toNumber(val)); 
	}
	
	onModifySingle[0] = function(val) { return onModifyIndex(0, val); }
	onModifySingle[1] = function(val) { return onModifyIndex(1, val); }
	onModifySingle[2] = function(val) { return onModifyIndex(2, val); }
	onModifySingle[3] = function(val) { return onModifyIndex(3, val); }
	
	onModifySingle[4] = function(val) { return onModifyIndex(4, val); }
	onModifySingle[5] = function(val) { return onModifyIndex(5, val); }
	onModifySingle[6] = function(val) { return onModifyIndex(6, val); }
	onModifySingle[7] = function(val) { return onModifyIndex(7, val); }
	
	onModifySingle[ 8] = function(val) { return onModifyIndex( 8, val); }
	onModifySingle[ 9] = function(val) { return onModifyIndex( 9, val); }
	onModifySingle[10] = function(val) { return onModifyIndex(10, val); }
	onModifySingle[11] = function(val) { return onModifyIndex(11, val); }
	
	onModifySingle[12] = function(val) { return onModifyIndex(12, val); }
	onModifySingle[13] = function(val) { return onModifyIndex(13, val); }
	onModifySingle[14] = function(val) { return onModifyIndex(14, val); }
	onModifySingle[15] = function(val) { return onModifyIndex(15, val); }
	
	extras = -1;
	
	for(var i = 0; i < inputs; i++) {
		tb[i] = new textBox(_type, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		b_link.interactable = interactable;
		
		for( var i = 0; i < inputs; i++ )
			tb[i].interactable = interactable;
		
		if(extras) 
			extras.interactable = interactable;
	}
	
	static register = function(parent = noone) {
		b_link.register(parent);
		
		for( var i = 0; i < inputs; i++ )
			tb[i].register(parent);
		
		if(extras) 
			extras.register(parent);
		
		if(unit != noone && unit.reference != noone)
			unit.triggerButton.register(parent);
	}
	
	static setSlideSpeed = function(speed) {
		for(var i = 0; i < inputs; i++)
			tb[i].slide_speed = speed;
	}
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		
		var hh = TEXTBOX_HEIGHT + ui(8);
		h = hh * size - ui(8);
		
		if(extras && instanceof(extras) == "buttonClass") {
			extras.setFocusHover(active, hover);			
			extras.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
			_w -= ui(40);
		}
		
		if(unit != noone && unit.reference != noone) {
			_w += ui(4);
			
			unit.triggerButton.setFocusHover(iactive, ihover);
			unit.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m);
			_w -= ui(40);
		}
		
		b_link.setFocusHover(active, hover);
		b_link.icon_index = linked;
		b_link.icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
		b_link.tooltip = linked? __txt("Unlink values") : __txt("Link values");
		
		var th = hh * size - ui(8);
		
		var bx = _x;
		var by = _y + th / 2 - ui(32 / 2);
		b_link.draw(bx + ui(4), by + ui(4), ui(24), ui(24), _m, THEME.button_hide);
		
		_x += ui(28);
		_w -= ui(28);
		
		var ww = _w / size;
		
		for(var i = 0; i < size; i++)
		for(var j = 0; j < size; j++) {
			var ind = i * size + j;
			tb[ind].setFocusHover(active, hover);
			
			var bx  = _x + ww * j;
			var by  = _y + hh * i;
			var _dat = array_safe_get(_data, ind);
			
			tb[ind].draw(bx + ui(8), by, ww - ui(8), TEXTBOX_HEIGHT, _dat, _m);
		}
		
		resetFocus();
		
		return h;
	}
}