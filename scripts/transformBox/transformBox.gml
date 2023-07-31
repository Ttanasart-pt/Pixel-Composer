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
	onModifySingle[TRANSFORM.rot  ] = function(val) { onModify(TRANSFORM.rot  , val); } //unused
	onModifySingle[TRANSFORM.sca_x] = function(val) { onModify(TRANSFORM.sca_x, val); }
	onModifySingle[TRANSFORM.sca_y] = function(val) { onModify(TRANSFORM.sca_y, val); }
	
	rot = new rotator(function(val) { onModify(TRANSFORM.rot  , val); });
	
	for(var i = 0; i < 5; i++) {
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		
		for( var i = 0, n = array_length(tb); i < n; i++ ) 
			tb[i].setInteract(interactable);
		rot.setInteract(interactable);
	}
	
	static register = function(parent = noone) {
		tb[TRANSFORM.pos_x].register(parent);
		tb[TRANSFORM.pos_y].register(parent);
		rot.register(parent);
		tb[TRANSFORM.sca_x].register(parent);
		tb[TRANSFORM.sca_y].register(parent);
	}
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = ui(148);
		
		rot.setFocusHover(active, hover);
		for(var i = 0; i < array_length(_data); i++)
			tb[i].setFocusHover(active, hover);
		
		var tbh = TEXTBOX_HEIGHT;
		var lbw = ui(80);
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_inner);
		draw_text_add(_x, _y + tbh / 2, "Position");
		
		var tbw = (_w - lbw) / 2 - ui(4);
		tb[TRANSFORM.pos_x].draw(_x + lbw,		         _y, tbw, tbh, _data[TRANSFORM.pos_x], _m);
		tb[TRANSFORM.pos_y].draw(_x + lbw + ui(8) + tbw, _y, tbw, tbh, _data[TRANSFORM.pos_y], _m);
		
		_y += ui(40);
		
		rot.draw(_x, _y, _w, _data[TRANSFORM.rot], _m);
		
		//draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_inner);
		//draw_text_add(_x + ui(8), _y + tbh / 2, "Rotation");
		
		_y += ui(72);
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_inner);
		draw_text_add(_x, _y + tbh / 2, "Scale");
		
		var tbw = array_length(_data) > 4? (_w - lbw) / 2 - ui(4) : _w - lbw;
		
		tb[TRANSFORM.sca_x].draw(_x + lbw, _y, tbw, tbh, _data[TRANSFORM.sca_x], _m);
		if(array_length(_data) > 4)
			tb[TRANSFORM.sca_y].draw(_x + lbw + ui(8) + tbw, _y, tbw, tbh, _data[TRANSFORM.sca_y], _m);
		
		resetFocus();
		
		return h;
	}
}