enum TRANSFORM {
	pos_x,
	pos_y,
	rot,
	sca_x,
	sca_y
}

function transformBox(_onModify) : widget() constructor {
	onModify = _onModify;
	
	onModifySingle[TRANSFORM.pos_x] = function(val) { onModify(TRANSFORM.pos_x, val); }
	onModifySingle[TRANSFORM.pos_y] = function(val) { onModify(TRANSFORM.pos_y, val); }
	onModifySingle[TRANSFORM.rot  ] = function(val) { onModify(TRANSFORM.rot  , val); }
	onModifySingle[TRANSFORM.sca_x] = function(val) { onModify(TRANSFORM.sca_x, val); }
	onModifySingle[TRANSFORM.sca_y] = function(val) { onModify(TRANSFORM.sca_y, val); }
	
	for(var i = 0; i < 5; i++) {
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		
		for( var i = 0; i < array_length(tb); i++ ) 
			tb[i].interactable = interactable;
	}
	
	static register = function(parent = noone) {
		for( var i = 0; i < array_length(tb); i++ ) 
			tb[i].register(parent);
	}
	
	static drawParam = function(param) {
		return draw(param.x, param.y, param.w, param.data, param.mouse);
	}
	
	static draw = function(_x, _y, _w, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = ui(192);
		
		for(var i = 0; i < array_length(_data); i++)
			tb[i].setFocusHover(active, hover);
		
		var tbh = TEXTBOX_HEIGHT;
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_inner);
		draw_text(_x + ui(8), _y + tbh / 2, "Position");
		
		var tbw = (_w - ui(64)) / 2 - ui(4);
		tb[TRANSFORM.pos_x].draw(_x + ui(64),			_y, tbw, tbh, _data[TRANSFORM.pos_x], _m);
		tb[TRANSFORM.pos_y].draw(_x + ui(64 + 8) + tbw, _y, tbw, tbh, _data[TRANSFORM.pos_y], _m);
		
		_y += ui(80);
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_inner);
		draw_text(_x + ui(8), _y + tbh / 2, "Scale");
		
		var tbw = array_length(_data) > 4? (_w - ui(64)) / 2 - ui(4) : _w - ui(64);
		
		tb[TRANSFORM.sca_x].draw(_x + ui(64), _y, tbw, tbh, _data[TRANSFORM.sca_x], _m);
		if(array_length(_data) > 4)
			tb[TRANSFORM.sca_y].draw(_x + ui(64 + 8) + tbw, _y, tbw, tbh, _data[TRANSFORM.sca_y], _m);
		
		resetFocus();
		
		return h;
	}
}