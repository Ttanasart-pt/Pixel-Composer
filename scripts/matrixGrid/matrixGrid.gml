function matrixGrid(_type, _size, _onModify, _unit = noone) : widget() constructor {
	type     = _type;
	size	 = 1;
	onModify = _onModify;
	unit	 = _unit;
	
	linked = false;
	b_link = button(function() /*=>*/ { linked = !linked; });
	b_link.icon = THEME.value_link;
	
	onModifyIndex = function(val, index) { 
		var modi = false;
		
		if(linked) {
			for( var i = 0; i < size * size; i++ )
				modi |= onModify(toNumber(val), i); 
			return modi;
		}
		
		return onModify(toNumber(val), index); 
	}
	
	extras = -1;
	
	static setSize = function(_size) {
		if(size == _size) return self;
		size = _size;
		
		for(var i = 0; i < size * size; i++) {
			tb[i] = new textBox(type, onModifyIndex);
			tb[i].onModifyParam = i;
			tb[i].slidable = true;
		}
		
		return self;
	} setSize(_size);
	
	static setInteract = function(interactable = false) { 
		self.interactable   = interactable;
		b_link.interactable = interactable;
		
		for( var i = 0; i < size * size; i++ )
			tb[i].interactable = interactable;
		
		if(extras) 
			extras.interactable = interactable;
	}
	
	static register = function(parent = noone) {
		b_link.register(parent);
		
		for( var i = 0; i < size * size; i++ )
			tb[i].register(parent);
		
		if(extras) 
			extras.register(parent);
		
		if(unit != noone && unit.reference != noone)
			unit.triggerButton.register(parent);
	}
	
	static isHovering = function() { 
		for( var i = 0, n = size * size; i < n; i++ ) if(tb[i].isHovering()) return true;
		return false;
	}
	
	static drawParam = function(params) {
		setParam(params);
		for(var i = 0; i < size * size; i++)
			tb[i].setParam(params);
	
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h * size;
		
		var ww = _w / size;
		
		var _bs = min(_h, ui(32));
		if((_w - _bs) / size > ui(64)) {
			if(extras && instanceof(extras) == "buttonClass") {
				extras.setFocusHover(active, hover);			
				extras.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide);
				_w -= _bs + ui(8);
			}
		
			if(unit != noone && unit.reference != noone) {
				_w += ui(4);
			
				unit.triggerButton.setFocusHover(iactive, ihover);
				unit.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m);
				_w -= _bs + ui(8);
			}
		
			b_link.setFocusHover(active, hover);
			b_link.icon_index = linked;
			b_link.icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
			b_link.tooltip = linked? __txt("Unlink values") : __txt("Link values");
				
			var th = _h * size - ui(8);
			var bx = _x;
			var by = _y + th / 2 - _bs / 2;
			b_link.draw(bx, by, _bs, _bs, _m, THEME.button_hide);
			
			_x += _bs + ui(4);
			_w -= _bs + ui(4);
		
		}
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, ww * size, _h * size, boxColor, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, ww * size, _h * size, boxColor, 0.5 + 0.5 * interactable);	
		
		for(var i = 0; i < size; i++)
		for(var j = 0; j < size; j++) {
			var ind = i * size + j;
			tb[ind].setFocusHover(active, hover);
			tb[ind].hide = true;
			
			var bx  = _x + ww * j;
			var by  = _y + _h * i;
			var _dat = array_safe_get_fast(_data, ind);
			
			tb[ind].draw(bx, by, ww, _h, _dat, _m);
		}
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() {
		var cln = new matrixGrid(type, size, onModify, unit);
		return cln;
	}
}