function matrixGrid(_type, _size, _onModify, _unit = noone) : widget() constructor {
	type     = _type;
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
			tb[i].setSlidable(speed);
	}
	
	static isHovering = function() { 
		for( var i = 0, n = array_length(tb); i < n; i++ ) if(tb[i].isHovering()) return true;
		return false;
	}
	
	static drawParam = function(params) {
		setParam(params);
		for(var i = 0; i < inputs; i++)
			tb[i].setParam(params);
	
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h * size;
		
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
		
		var ww = _w / size;
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, ww * size, _h * size, c_white, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, ww * size, _h * size, c_white, 0.5 + 0.5 * interactable);	
		
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
	
	static clone = function() { #region
		var cln = new matrixGrid(type, size, onModify, unit);
		
		return cln;
	} #endregion
}