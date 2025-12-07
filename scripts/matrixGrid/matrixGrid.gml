function matrixGrid(_type, _onModify, _unit = noone) : widget() constructor {
	type     = _type;
	size	 = [1, 1];
	vsize    = 0;
	onModify = _onModify;
	unit	 = _unit;
	
	tb = [];
	linked = false;
	b_link = button(function() /*=>*/ { linked = !linked; }).setIcon(THEME.value_link).iconPad();
	
	onModifyIndex = function(val, index) { 
		var modi = false;
		
		if(linked) {
			for( var i = 0; i < vsize; i++ )
				modi = onModify(toNumber(val), i) || modi;
			return modi;
		}
		
		return onModify(toNumber(val), index); 
	}
	
	extras = -1;
	
	static setSize = function(_size) {
		if(!is_array(_size)) _size = [ _size, _size ];
		if(size[0] == _size[0] && size[1] == _size[1]) return self;
		
		size  = _size;
		vsize = size[0] * size[1];
		
		for(var i = 0; i < vsize; i++) {
			tb[i] = new textBox(type, onModifyIndex);
			tb[i].onModifyParam = i;
			tb[i].slidable = true;
		}
		
		return self;
	} setSize(1);
	
	static setInteract = function(interactable = false) { 
		self.interactable   = interactable;
		b_link.interactable = interactable;
		
		for( var i = 0; i < vsize; i++ )
			tb[i].interactable = interactable;
		
		if(extras) 
			extras.interactable = interactable;
	}
	
	static register = function(parent = noone) {
		b_link.register(parent);
		
		for( var i = 0; i < vsize; i++ )
			tb[i].register(parent);
		
		if(extras) 
			extras.register(parent);
		
		if(unit != noone && unit.reference != noone)
			unit.triggerButton.register(parent);
	}
	
	static isHovering = function() { 
		for( var i = 0, n = vsize; i < n; i++ ) if(tb[i].isHovering()) return true;
		return false;
	}
	
	static fetchHeight = function(params) { if(is(params.data, Matrix)) setSize(params.data.size); return params.h * size[1]; }
	static drawParam   = function(params) {
		setParam(params);
		for(var i = 0; i < vsize; i++)
			tb[i].setParam(params);
	
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		if(is(_data, Matrix)) setSize(_data.size);
		
		x = _x;
		y = _y;
		w = _w;
		h = _h * size[1];
		
		var ww = _w / size[0];
		
		var _bs = min(_h, ui(32));
		if((_w - _bs) / size[0] > ui(64)) {
			if(extras && instanceof(extras) == "buttonClass") {
				extras.setFocusHover(active, hover);			
				extras.draw(_x + _w - _bs, _y + _h / 2 - _bs / 2, _bs, _bs, _m, THEME.button_hide_fill);
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
				
			var th = _h * size[1] - ui(8);
			var bx = _x;
			var by = _y + th / 2 - _bs / 2;
			b_link.draw(bx, by, _bs, _bs, _m, THEME.button_hide_fill);
			
			_x += _bs + ui(4);
			_w -= _bs + ui(4);
		
		}
		
		if(hide == 0) {
			draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, ww * size[0], _h * size[1], boxColor, 1);
			draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, ww * size[0], _h * size[1], boxColor, 0.5 + 0.5 * interactable);	
		}
		
		var _raw = is(_data, Matrix)? _data.raw : _data;
		
		for(var i = 0; i < size[1]; i++)
		for(var j = 0; j < size[0]; j++) {
			var ind = i * size[0] + j;
			var _tb = array_safe_get_fast(tb, ind);
			if(!is(_tb, widget)) continue;
			
			_tb.setFocusHover(active, hover);
			_tb.hide = true;
			
			var bx  = _x + ww * j;
			var by  = _y + _h * i;
			var _dat = array_safe_get_fast(_raw, ind);
			
			_tb.draw(bx, by, ww, _h, _dat, _m);
		}
		
		resetFocus();
		
		return h;
	}
	
	static clone = function() {
		var cln = new matrixGrid(type, onModify, unit);
		return cln;
	}

	static free = function() {
		for( var i = 0, n = array_length(tb); i < n; i++ ) tb[i].free();
	}
}