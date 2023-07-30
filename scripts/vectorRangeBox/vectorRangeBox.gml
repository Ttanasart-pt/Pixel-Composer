function vectorRangeBox(_size, _type, _onModify, _unit = noone) : widget() constructor {
	size     = _size;
	onModify = _onModify;
	unit	 = _unit;
	
	linked = false;
	b_link = button(function() { linked = !linked; });
	b_link.icon = THEME.value_link;
	
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
	label = [];
	onModifySingle[0] = function(val) { return onModifyIndex(0, toNumber(val)); }
	onModifySingle[1] = function(val) { return onModifyIndex(1, toNumber(val)); }
	onModifySingle[2] = function(val) { return onModifyIndex(2, toNumber(val)); }
	onModifySingle[3] = function(val) { return onModifyIndex(3, toNumber(val)); }
	
	extras = -1;
	
	for(var i = 0; i < size; i++) {
		tb[i] = new textBox(_type, onModifySingle[i]);
		tb[i].slidable = true;
		
		label[i] = (i % 2? __txt("Max") : __txt("Min")) + " " + axis[floor(i / 2)];
	}
	
	static setSlideSpeed = function(speed) {
		for(var i = 0; i < size; i++)
			tb[i].slide_speed = speed;
	}
	
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
		if(extras) extras.register(parent);
	}
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h * 2 + ui(4);
		
		b_link.setFocusHover(active, hover);
		b_link.icon_index = linked;
		b_link.icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
		b_link.tooltip = linked? __txt("Unlink values") : __txt("Link values");
		
		var bx = _x;
		var by = _y + _h / 2 - ui(32 / 2);
		b_link.draw(bx + ui(4), by + ui(4), ui(24), ui(24), _m, THEME.button_hide);
		
		_x += ui(28);
		_w -= ui(28);
		
		if(extras && instanceof(extras) == "buttonClass") {
			extras.setFocusHover(active, hover);
			extras.draw(_x + _w - ui(32), _y + _h / 2 - ui(32 / 2), ui(32), ui(32), _m, THEME.button_hide);
			_w -= ui(40);
		}
		
		var ww  = _w / size * 2;
		for(var i = 0; i < size; i++) {
			tb[i].setFocusHover(active, hover);
			
			var bx  = _x + ww * floor(i / 2);
			var by  = _y + i % 2 * (_h + ui(4));
			tb[i].draw(bx + ui(56), by, ww - ui(56), _h, _data[i], _m);
			
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_inner);
			draw_text(bx + ui(8), by + _h / 2, label[i]);
		}
		
		resetFocus();
		
		return _h * 2 + ui(4);
	}
}