enum TRANSFORM {
	pos_x,
	pos_y,
	rot,
	sca_x,
	sca_y
}

function transformBox(_onModify) : widget() constructor {
	#region data
		always_break_line  = true;
		onModify = _onModify;
		
		onModifySingle[TRANSFORM.pos_x] = function(val) /*=>*/ { onModify(val, TRANSFORM.pos_x); }
		onModifySingle[TRANSFORM.pos_y] = function(val) /*=>*/ { onModify(val, TRANSFORM.pos_y); }
		onModifySingle[TRANSFORM.rot  ] = function(val) /*=>*/ { onModify(val, TRANSFORM.rot  ); } //unused
		onModifySingle[TRANSFORM.sca_x] = function(val) /*=>*/ { onModify(val, TRANSFORM.sca_x); }
		onModifySingle[TRANSFORM.sca_y] = function(val) /*=>*/ { onModify(val, TRANSFORM.sca_y); }
		
		rot = new rotator(function(val) /*=>*/ { onModify(val, TRANSFORM.rot); });
		
		labels = [ "x", "y", "rot", "sx", "sy" ];
		
		for(var i = 0; i < 5; i++) {
			tb[i] = textBox_Number(onModifySingle[i]);
			tb[i].slidable = true;
			tb[i].label    = labels[i];
		}
		
		rot.tb_value.label = "rot";
	#endregion
	
	////- Setters
	
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
	
	static isHovering = function() { 
		for( var i = 0, n = array_length(tb); i < n; i++ ) if(tb[i].isHovering()) return true;
		return hovering;
	}
	
	////- Draw
	
	static drawParam = function(params) {
		setParam(params);
		rot.hide = hide;
        rot.setParam(params);
		rot.tb_value.setParam(params);
		
		for(var i = 0; i < 5; i++) tb[i].setParam(params);
		
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
		
		hovering = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h);
		
		var tbHover = hover;
		for(var i = 0; i < array_length(_data); i++) tb[i].hide = true;
		
	 	h = _h;
	 	
	 	var _spc = ui(4);
	 	var _tbw = (w - _spc * 2) / array_length(_data);
	 	var _tbh = _h;
	 	var _tbx = _x;
	 	
	 	if(hide == 0) {
		 	draw_sprite_stretched_ext(THEME.textbox, 3, _tbx, _y, _tbw * 2, _tbh, boxColor, 1);
			draw_sprite_stretched_ext(THEME.textbox, 0, _tbx, _y, _tbw * 2, _tbh, boxColor, 0.5 + 0.5 * interactable);	
	 	}
	 	
	 	tb[TRANSFORM.pos_x].setFocusHover(active, tbHover);
	 	tb[TRANSFORM.pos_x].draw(_tbx,        _y, _tbw, _tbh, _data[TRANSFORM.pos_x], _m);
		tbHover &= !tb[TRANSFORM.pos_x].isHovering();
	 	
	 	tb[TRANSFORM.pos_y].setFocusHover(active, tbHover);
		tb[TRANSFORM.pos_y].draw(_tbx + _tbw, _y, _tbw, _tbh, _data[TRANSFORM.pos_y], _m);
		tbHover &= !tb[TRANSFORM.pos_y].isHovering();
	 	
	 	_tbx += _tbw * 2 + _spc;
	 	
	 	rot.setFocusHover(active, tbHover);
	 	rot.draw(_tbx, _y, _tbw, _tbh, _data[TRANSFORM.rot], _m);
	 	tbHover &= !rot.isHovering();
	 	
	 	_tbx += _tbw + _spc;
	 	
	 	if(array_length(_data) == 4) {
	 		if(hide == 0) {
			 	draw_sprite_stretched_ext(THEME.textbox, 3, _tbx, _y, _tbw, _tbh, boxColor, 1);
				draw_sprite_stretched_ext(THEME.textbox, 0, _tbx, _y, _tbw, _tbh, boxColor, 0.5 + 0.5 * interactable);	
	 		}
			
			tb[TRANSFORM.sca_x].setFocusHover(active, tbHover);
			tb[TRANSFORM.sca_x].draw(_tbx, _y, _tbw, _tbh, _data[TRANSFORM.sca_x], _m);
			tbHover &= !tb[TRANSFORM.sca_x].isHovering();
	 		
	 	} else if(array_length(_data) == 5) {
	 		if(hide == 0) {
		 		draw_sprite_stretched_ext(THEME.textbox, 3, _tbx, _y, _tbw * 2, _tbh, boxColor, 1);
				draw_sprite_stretched_ext(THEME.textbox, 0, _tbx, _y, _tbw * 2, _tbh, boxColor, 0.5 + 0.5 * interactable);	
	 		}
			
			tb[TRANSFORM.sca_x].setFocusHover(active, tbHover);
			tb[TRANSFORM.sca_x].draw(_tbx,        _y, _tbw, _tbh, _data[TRANSFORM.sca_x], _m);
			tbHover &= !tb[TRANSFORM.sca_x].isHovering();
			
			tb[TRANSFORM.sca_y].setFocusHover(active, tbHover);
			tb[TRANSFORM.sca_y].draw(_tbx + _tbw, _y, _tbw, _tbh, _data[TRANSFORM.sca_y], _m);
			tbHover &= !tb[TRANSFORM.sca_y].isHovering();
	 	}
		
		resetFocus();
		
		return h;
	}
	
	////- Action
	
	static clone = function() {
		var cln = new transformBox(onModify);
		
		return cln;
	}
	
	static free = function() {
		for( var i = 0, n = array_length(tb); i < n; i++ ) tb[i].free();
	}
}