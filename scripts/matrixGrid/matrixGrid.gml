function matrixGrid(_type, _onModify, _unit = noone) : widget() constructor {
	type     = _type;
	size	 = [1, 1];
	vsize    = 0;
	onModify = _onModify;
	unit	 = _unit;
	current_data = undefined;
	
	tb     = [];
	linked = false;
	tbsize = new vectorBox(2, function(v,i) /*=>*/ { 
		if(current_data == undefined) return;
		
		_size    = [size[0], size[1]]; 
		_size[i] = max(1, v); 
		setSize(_size); 
		
		current_data.setSize(_size);
		onModify(current_data.raw[0], 0); 
	});
		
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
		tbsize.interactable = interactable;
		
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
	
	static onSetParam = function(params) {
		tbsize.setParam(params);
		for(var i = 0; i < vsize; i++)
			tb[i].setParam(params);
	}
	
	static drawParam   = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _display_data, _m) {
		if(is(_data, Matrix)) setSize(_data.size);
		
		var gridh  = _h * size[1];
		var resize = _display_data[$ "resizeable"] ?? true;
		    resize = resize && interactable;
		current_data = _data;
		
		x = _x;
		y = _y;
		w = _w;
		h = gridh + resize * (_h + ui(4));
		
		if(resize) {
			tbsize.setFocusHover(active, hover);
			tbsize.draw(_x, _y, _w, _h, size, {}, _m);
			_y += _h + ui(4);
		}
		
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, gridh, boxColor, 1);
		
		var bs = min(_h, ui(32));
		if((_w - bs) / size[0] > ui(64)) {
			var bx = _x + _w - bs;
			
			if(is(extras, buttonClass)) {
				if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, bx, _y, bs, gridh, CDEF.main_mdwhite, 1);
				extras.setFocusHover(active, hover);			
				extras.draw(bx, _y + _h / 2 - bs / 2, bs, bs, _m, THEME.button_hide_fill);
				_w -= bs;
			}
		
			b_link.setFocusHover(active, hover);
			b_link.icon_index = linked;
			b_link.icon_blend = linked? COLORS._main_accent : COLORS._main_icon;
			b_link.tooltip = linked? __txt("Unlink values") : __txt("Link values");
			
			var bx = _x;
			var by = _y;
			
			if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, bx, _y, bs, gridh, CDEF.main_mdwhite, 1);
			b_link.draw(bx, by, bs, bs, _m, THEME.button_hide_fill);
			
			by += _h;
			if(unit != noone && unit.reference != noone) {
				unit.triggerButton.setFocusHover(iactive, ihover);
				unit.draw(bx, by, bs, bs, _m);
			}
			
			_x += bs;
			_w -= bs;
		
		}
		
		var ww = _w / size[0];
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, gridh, boxColor, 0.5 + 0.5 * interactable);	
		
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