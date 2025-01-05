function pathAnchorBox(_onModify) : widget() constructor {
	onModify = _onModify;
	
	onModifySingle[0] = function(val) /*=>*/ {return onModify(toNumber(val), 0)};
	onModifySingle[1] = function(val) /*=>*/ {return onModify(toNumber(val), 1)};
	onModifySingle[2] = function(val) /*=>*/ {return onModify(toNumber(val), 2)};
	onModifySingle[3] = function(val) /*=>*/ {return onModify(toNumber(val), 3)};
	onModifySingle[4] = function(val) /*=>*/ {return onModify(toNumber(val), 4)};
	onModifySingle[5] = function(val) /*=>*/ {return onModify(toNumber(val), 5)};
	
	onModifySingle[6] = function(val) /*=>*/ {return onModify(toNumber(val), 6)}; //3d
	onModifySingle[7] = function(val) /*=>*/ {return onModify(toNumber(val), 7)};
	onModifySingle[8] = function(val) /*=>*/ {return onModify(toNumber(val), 8)};
	
	for(var i = 0; i < 9; i++) tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]).setPrecision(2).setHide(1);
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		
		for( var i = 0, n = array_length(tb); i < n; i++ )
			tb[i].interactable = interactable;
	}
	
	static register = function(parent = noone) {
		for( var i = 0, n = array_length(tb); i < n; i++ )
			tb[i].register(parent);
	}
	
	static isHovering = function() { 
		for( var i = 0, n = array_length(tb); i < n; i++ ) 
			if(tb[i].isHovering()) return true;
		return false;
	}
	
	static drawParam = function(params) {
		setParam(params);
		for(var i = 0; i < array_length(tb); i++) tb[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h * 2 + 6;
		
		for( var i = 0, n = array_length(tb); i < n; i++ ) 
			tb[i].setFocusHover(active, hover);
		
		
		var _tx, _ty, _tw, _th, _w2;
		var _bw = ui(28);
		var _li = 6;
		
		if(array_length(_data) < 9) {
			tb[0].setLabel("x");
			tb[1].setLabel("y");
			
			tb[2].setLabel("dx0");
			tb[3].setLabel("dy0");
			tb[4].setLabel("dx1");
			tb[5].setLabel("dy1");
				
			_tx = _x;
			_ty = _y;
			_tw = _w / 2;
			_th = _h;
			
			draw_sprite_stretched(THEME.textbox, 3, _tx, _ty, _w, _th);
			tb[0].draw(_tx,       _ty, _tw, _th, _data[0], _m);
			tb[1].draw(_tx + _tw, _ty, _tw, _th, _data[1], _m);
			
			_ty = _y + _th + 6;
			_w2 = _w / 2 - _bw / 2 - 4;
			_tw = _w2 / 2;
			
			draw_sprite_stretched(THEME.textbox, 3, _tx, _ty, _w2, _th);
			tb[2].draw(_tx + _tw * 0, _ty, _tw, _th, _data[2], _m);
			tb[3].draw(_tx + _tw * 1, _ty, _tw, _th, _data[3], _m);
			
			_tx = _x + _w - _w2;
			
			draw_sprite_stretched(THEME.textbox, 3, _tx, _ty, _w2, _th);
			tb[4].draw(_tx + _tw * 0, _ty, _tw, _th, _data[4], _m);
			tb[5].draw(_tx + _tw * 1, _ty, _tw, _th, _data[5], _m);
			
		} else {
			tb[0].setLabel("x");
			tb[1].setLabel("y");
			tb[2].setLabel("z");
			
			tb[3].setLabel("dx0");
			tb[4].setLabel("dy0");
			tb[5].setLabel("dz0");
			
			tb[6].setLabel("dx1");
			tb[7].setLabel("dy1");
			tb[8].setLabel("dz1");
			
			_li = 9;
			_tx = _x;
			_ty = _y;
			_tw = _w / 3;
			_th = _h;
			
			draw_sprite_stretched(THEME.textbox, 3, _tx, _ty, _w, _th);
			tb[0].draw(_tx + _tw * 0, _ty, _tw, _th, _data[0], _m);
			tb[1].draw(_tx + _tw * 1, _ty, _tw, _th, _data[1], _m);
			tb[2].draw(_tx + _tw * 2, _ty, _tw, _th, _data[2], _m);
			
			_ty = _y + _th + 6;
			_w2 = _w / 2 - _bw / 2 - 4;
			_tw = _w2 / 3;
			
			draw_sprite_stretched(THEME.textbox, 3, _tx, _ty, _w2, _th);
			tb[3].draw(_tx + _tw * 0, _ty, _tw, _th, _data[3], _m);
			tb[4].draw(_tx + _tw * 1, _ty, _tw, _th, _data[4], _m);
			tb[5].draw(_tx + _tw * 2, _ty, _tw, _th, _data[5], _m);
								
			_tx = _x + _w - _w2;
			
			draw_sprite_stretched(THEME.textbox, 3, _tx, _ty, _w2, _th);
			tb[6].draw(_tx + _tw * 0, _ty, _tw, _th, _data[6], _m);
			tb[7].draw(_tx + _tw * 1, _ty, _tw, _th, _data[7], _m);
			tb[8].draw(_tx + _tw * 2, _ty, _tw, _th, _data[8], _m);
			
		}
		
		var _linked = array_safe_get(_data, _li);
		var _blend  = !_linked? COLORS._main_accent : COLORS._main_icon;
		var bx =  _x +  _w / 2 - _bw / 2;
		var by = _ty + _th / 2 - _bw / 2;
		
		if(buttonInstant(THEME.button_hide_fill, bx, by, _bw, _bw, _m, hover, active, "Linked", THEME.value_link, !_linked, _blend) == 2)
			onModify(!_linked, _li);
		
		resetFocus();
		return h;
	}
	
	static clone = function() { return new pathAnchorBox(onModify); }
	static free  = function() { array_foreach(tb, function(t) /*=>*/ {return t.free()}); }
}