enum QUARTERNION_DISPLAY {
	quarterion,
	euler,
}

function quarternionBox(_onModify) : widget() constructor {
	onModify = _onModify;
	current_value = [];
	
	onModifyIndex = function(index, val) { 
		var v = toNumber(val);
		
		if(is_callable(onModify))
			return onModify(index, v); 
		return noone;
	}
	
	size    = 4;
	axis    = [ "x", "y", "z", "w" ];
	tooltip = new tooltipSelector("Angle type", ["Quaternion", "Euler"]);
	
	disp_w    = noone;
	clickable = true;
	
	onModifySingle[0] = function(val) { return onModifyIndex(0, val); }
	onModifySingle[1] = function(val) { return onModifyIndex(1, val); }
	onModifySingle[2] = function(val) { return onModifyIndex(2, val); }
	onModifySingle[3] = function(val) { return onModifyIndex(3, val); }
	
	for(var i = 0; i < 4; i++) {
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	static setSlideSpeed = function(speed) {
		for(var i = 0; i < size; i++)
			tb[i].slide_speed = speed;
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
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.h, params.data, params.extra_data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _extra_data, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = _h;
		
		if(!is_array(_data))   return 0;
		if(array_empty(_data)) return 0;
		if(is_array(_data[0])) return 0;
		
		current_value = _data;
		
		var bs = ui(32);
		var bx = _x + _w - bs;
		var by = _y + _h / 2 - bs / 2;
		var _disp = struct_try_get(_extra_data, "angle_display");
		tooltip.index = _disp;
		
		if(buttonInstant(THEME.button_hide, bx, by, bs, bs, _m, active, hover, tooltip, THEME.unit_angle, _disp, c_white) == 2) {
			clickable = false;
			_extra_data.angle_display = (_disp + 1) % 2;
		}
		_w -= ui(40);
		
		size = _disp? 3 : 4;
		var ww = _w / size;
		var bx = _x;
		disp_w = disp_w == noone? ww : lerp_float(disp_w, ww, 3);
		
		for(var i = 0; i < size; i++) {
			tb[i].setFocusHover(clickable && active, hover);
			tb[i].draw(bx + ui(24), _y, disp_w - ui(24), _h, _data[i], _m);
			
			draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_inner);
			draw_text(bx + ui(8), _y + _h / 2, axis[i]);
			
			bx += disp_w;
		}
		
		clickable = true;
		resetFocus();
		
		return _h;
	}
	
	static apply = function() {
		for( var i = 0; i < size; i++ ) {
			tb[i].apply();
			current_value[i] = toNumber(tb[i]._input_text);
		}
	}
}