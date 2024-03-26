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
	
	rot = new rotator(function(val) { onModify(TRANSFORM.rot, val); });
	
	labels = [ "x", "y", "rot", "sx", "sy" ];
	
	for(var i = 0; i < 5; i++) {
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		tb[i].slidable = true;
		tb[i].label    = labels[i];
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
		font = params.font;
		rot.font = params.font;
		for(var i = 0; i < 5; i++) tb[i].font = params.font;
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.m); 
	}
	
	static draw = function(_x, _y, _w, _h, _data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h * 3 + ui(4) * 2;
		
		if(!is_array(_data))   return 0;
		if(array_empty(_data)) return 0;
		if(is_array(_data[0])) return 0;
		
		rot.setFocusHover(active, hover);
		for(var i = 0; i < array_length(_data); i++) {
			tb[i].setFocusHover(active, hover);
			tb[i].hide = true;
		}
		
		draw_set_text(font, fa_left, fa_center, CDEF.main_dkgrey);
		
		var lbw = string_width(__txt("Position")) + ui(8);
		var tbw = (_w - lbw) / 2;
		var tbh = _h;
		
		draw_text_add(_x, _y + tbh / 2, __txt("Position"));
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x + lbw, _y, _w - lbw, tbh, c_white, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x + lbw, _y, _w - lbw, tbh, c_white, 0.5 + 0.5 * interactable);	
		
		tb[TRANSFORM.pos_x].draw(_x + lbw,		 _y, tbw, tbh, _data[TRANSFORM.pos_x], _m);
		tb[TRANSFORM.pos_y].draw(_x + lbw + tbw, _y, tbw, tbh, _data[TRANSFORM.pos_y], _m);
		
		_y += tbh + ui(4);
		
		rot.draw(_x, _y, _w, tbh, _data[TRANSFORM.rot], _m);
		
		_y += tbh + ui(4);
		
		draw_set_text(font, fa_left, fa_center, CDEF.main_dkgrey);
		draw_text_add(_x, _y + tbh / 2, __txt("Scale"));
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x + lbw, _y, _w - lbw, tbh, c_white, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x + lbw, _y, _w - lbw, tbh, c_white, 0.5 + 0.5 * interactable);	
		
		tbw = array_length(_data) > 4? (_w - lbw) / 2 : _w - lbw;
		
		tb[TRANSFORM.sca_x].draw(_x + lbw, _y, tbw, tbh, _data[TRANSFORM.sca_x], _m);
		if(array_length(_data) > 4)
			tb[TRANSFORM.sca_y].draw(_x + lbw + tbw, _y, tbw, tbh, _data[TRANSFORM.sca_y], _m);
		
		resetFocus();
		
		return h;
	}
}