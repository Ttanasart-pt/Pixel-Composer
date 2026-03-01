enum QUARTERNION_DISPLAY {
	quarterion,
	euler,
}

function quarternionBox(_onModify) : widget() constructor {
	onModify      = _onModify;
	current_value = [ 0, 0, 0, 0 ];
	current_unit  = QUARTERNION_DISPLAY.quarterion;
	
	onModifyIndex = function(val, index) { 
		var v = toNumber(val);
		
		if(current_unit == QUARTERNION_DISPLAY.quarterion) {
			return onModify(v, index); 
			
		} else {
			var v  = toNumber(val);
			var qv = [
				current_value[0], 
				current_value[1], 
				current_value[2], 
			];
			
			qv[index] = v;
			return onModify(qv);
		}
	}
	
	size    = 4;
	axis    = [ "x", "y", "z", "w" ];
	tooltip = new tooltipSelector("Angle type", [__txt("Quaternion"), __txt("Euler")]);
	
	disp_w    = noone;
	clickable = true;
	
	onModifySingle[0] = function(val) { return onModifyIndex(val, 0); }
	onModifySingle[1] = function(val) { return onModifyIndex(val, 1); }
	onModifySingle[2] = function(val) { return onModifyIndex(val, 2); }
	onModifySingle[3] = function(val) { return onModifyIndex(val, 3); }
	
	for(var i = 0; i < 4; i++) {
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		tb[i].slidable = true;
		tb[i].label    = axis[i];
	}
	
	static setInteract = function(interactable) { 
		self.interactable = interactable;
		
		for( var i = 0; i < size; i++ ) 
			tb[i].interactable = interactable;
	}
	
	static register = function(parent = noone) {
		for( var i = 0; i < size; i++ ) 
			tb[i].register(parent);
	}
	
	static isHovering = function() { 
		for( var i = 0, n = array_length(tb); i < n; i++ ) if(tb[i].isHovering()) return true;
		return false;
	}
	
	static apply = function() {
		for( var i = 0; i < size; i++ ) {
			tb[i].apply();
			current_value[i] = toNumber(tb[i]._input_text);
		}
	}
	
	static drawParam = function(params) {
		setParam(params);
		for(var i = 0; i < 4; i++) tb[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _display_data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		if(!is_array(_data))   return 0;
		if(array_empty(_data)) return 0;
		if(is_array(_data[0])) return 0;
		
		var _disp = struct_try_get(attributes, "angle_display");
		
		if(attributes.angle_display == QUARTERNION_DISPLAY.quarterion || (!tb[0].sliding && !tb[1].sliding && !tb[2].sliding)) {
			current_value[0] = array_safe_get(_data, 0);
			current_value[1] = array_safe_get(_data, 1);
			current_value[2] = array_safe_get(_data, 2);
			current_value[3] = array_safe_get(_data, 3);
		}
		
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, x, y, w, h, boxColor, 1);
		
		var bs = min(_h, ui(32));
		if((_w - bs) / 2 > ui(64)) {
			var bx = _x + _w - bs;
			var by = _y + _h / 2 - bs / 2;
			var tg = false;
			tooltip.index = _disp;
			
			if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, bx, _y, bs, _h, CDEF.main_mdwhite, 1);
			var b = buttonInstant_Pad(THEME.button_hide_fill, bx, by, bs, bs, _m, ihover, iactive, tooltip, THEME.unit_angle, _disp, c_white);
			if(b == 1 && key_mod_press(SHIFT) && MOUSE_WHEEL != 0) tg = true;
			if(b == 2) tg = true;
				
			if(tg) {
				setAttribute("angle_display", (_disp + 1) % 2);
				onModify(current_value[0], 0);
				clickable = false;
			}
			_w -= bs;
		}
		
		current_unit = attributes.angle_display;
			
		size = _disp? 3 : 4;
		var ww = _w / size;
		var bx = _x;
		disp_w = disp_w == noone? ww : lerp_float(disp_w, ww, 3);
		
		var _dispDat = _data;
		
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 0, x, y, w, h, boxColor, 0.5 + 0.5 * interactable);	
		
		for(var i = 0; i < size; i++) {
			var _a = array_safe_get(_dispDat, i, 0);
			
			tb[i].hide = true;
			tb[i].setFocusHover(clickable && active, hover);
			tb[i].draw(bx, _y, disp_w, _h, _a, _m);
			
			bx += disp_w;
		}
		
		clickable = true;
		resetFocus();
		
		return _h;
	}
	
	static clone = function() {
		var cln = new quarternionBox(onModify);
		return cln;
	}
	
	static free = function() {
		for( var i = 0, n = array_length(tb); i < n; i++ ) tb[i].free();
	}
}