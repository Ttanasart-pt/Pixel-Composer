function matrixGrid(_type, _onModify, _unit = noone) : widget() constructor {
	size	 = 9;
	onModify = _onModify;
	unit	 = _unit;
	
	linked = false;
	b_link = button(function() { linked = !linked; });
	b_link.icon = THEME.value_link;
	
	onModifyIndex = function(index, val) { 
		var modi = false;
		
		if(linked) {
			for( var i = 0; i < size; i++ )
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
	onModifySingle[8] = function(val) { return onModifyIndex(8, val); }
	
	extras = -1;
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		b_link.interactable = interactable;
		
		for( var i = 0; i < size; i++ )
			tb[i].interactable = interactable;
		
		if(extras) 
			extras.interactable = interactable;
	}
	
	static register = function(parent = noone) {
		b_link.register(parent);
		
		for( var i = 0; i < size; i++ )
			tb[i].register(parent);
		
		if(extras) 
			extras.register(parent);
		
		if(unit != noone && unit.reference != noone)
			unit.triggerButton.register(parent);
	}
	
	for(var i = 0; i < size; i++) {
		tb[i] = new textBox(_type, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	static setSlideSpeed = function(speed) {
		for(var i = 0; i < size; i++)
			tb[i].slide_speed = speed;
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		if(extras && instanceof(extras) == "buttonClass") {
			extras.setActiveFocus(hover, active);			
			extras.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
			_w -= ui(40);
		}
		
		if(unit != noone && unit.reference != noone) {
			_w += ui(4);
			
			unit.triggerButton.setActiveFocus(ihover, iactive);
			unit.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m);
			_w -= ui(40);
		}
		
		b_link.setActiveFocus(hover, active);
		b_link.icon_index = linked;
		b_link.icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
		b_link.tooltip = linked? __txt("Unlink values") : __txt("Link values");
		
		var hh = TEXTBOX_HEIGHT + ui(8);
		var th = hh * 3 - ui(8);
		
		var bx = _x;
		var by = _y + th / 2 - ui(32 / 2);
		b_link.draw(bx + ui(4), by + ui(4), ui(24), ui(24), _m, THEME.button_hide);
		
		_x += ui(28);
		_w -= ui(28);
		
		var ww = _w / 3;
		
		for(var i = 0; i < 3; i++)
		for(var j = 0; j < 3; j++) {
			var ind = i * 3 + j;
			tb[ind].setActiveFocus(hover, active);
			
			var bx  = _x + ww * j;
			var by  = _y + hh * i;
			
			tb[ind].draw(bx + ui(8), by, ww - ui(8), TEXTBOX_HEIGHT, _data[ind], _m);
		}
		
		resetFocus();
		
		return th;
	}
}