function pathAnchorBox(_onModify) : widget() constructor {
	onModify = _onModify;
	
	onModifySingle[0] = function(val) { return onModify(0, toNumber(val)); }
	onModifySingle[1] = function(val) { return onModify(1, toNumber(val)); }
	
	onModifySingle[2] = function(val) { return onModify(2, toNumber(val)); }
	onModifySingle[3] = function(val) { return onModify(3, toNumber(val)); }
	onModifySingle[4] = function(val) { return onModify(4, toNumber(val)); }
	onModifySingle[5] = function(val) { return onModify(5, toNumber(val)); }
	
	for(var i = 0; i < 6; i++) {
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	tb[0].setPrecision(2).setLabel("x");
	tb[1].setPrecision(2).setLabel("y");
	tb[2].setPrecision(2).setLabel("dx0");
	tb[3].setPrecision(2).setLabel("dy0");
	tb[4].setPrecision(2).setLabel("dx1");
	tb[5].setPrecision(2).setLabel("dy1");
	
	static setSlideSpeed = function(speed) {
		for( var i = 0, n = array_length(tb); i < n; i++ )
			tb[i].setSlidable(speed);
	}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		
		for( var i = 0, n = array_length(tb); i < n; i++ )
			tb[i].interactable = interactable;
	}
	
	static register = function(parent = noone) {
		for( var i = 0, n = array_length(tb); i < n; i++ )
			tb[i].register(parent);
	}
	
	static drawParam = function(params) {
		setParam(params);
		for(var i = 0; i < 6; i++) tb[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h * 2 + 6;
		
		for( var i = 0, n = array_length(tb); i < n; i++ ) 
			tb[i].setFocusHover(active, hover);
		
		var _tx = _x, _ty = _y;
		var _tw = _w / 2 - 4;
		var _th = _h;
		
		tb[0].draw(_tx,          _ty, _tw, _th, _data[0], _m);
		tb[1].draw(_tx + _w / 2, _ty, _tw, _th, _data[1], _m);
		
		var _bw = ui(28);
		var _ty = _y + _th + 6;
		var _tw = (_w - _bw - 8) / 4 - 4;
		
		tb[2].draw(_tx + (_tw + 4) * 0, _ty, _tw, _th, _data[2], _m);
		tb[3].draw(_tx + (_tw + 4) * 1, _ty, _tw, _th, _data[3], _m);
									  
		tb[4].draw(_tx + (_tw + 4) * 2 + _bw + 8, _ty, _tw, _th, _data[4], _m);
		tb[5].draw(_tx + (_tw + 4) * 3 + _bw + 8, _ty, _tw, _th, _data[5], _m);
		
		var _linked = _data[6];
		var _blend  = !_linked? COLORS._main_accent : COLORS._main_icon;
		var bx =  _x +  _w / 2 - _bw / 2 - 2;
		var by = _ty + _th / 2 - _bw / 2;
		
		if(buttonInstant(THEME.button_hide, bx, by, _bw, _bw, _m, active, hover, "Linked", THEME.value_link, !_linked, _blend) == 2)
			onModify(6, !_linked);
		
		resetFocus();
		return h;
	}
}