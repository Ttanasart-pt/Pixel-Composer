function areaBox(_onModify, _unit = noone) : widget() constructor {
	onModify = _onModify;
	unit	 = _unit;
	onSurfaceSize = -1;
	
	link_value	 = false;
	current_data = [ 0, 0, 0, 0 ];
	adjust_shape = true;
	mode		 = AREA_MODE.area;
	tooltip		 = new tooltipSelector("Area type", [
		__txtx("widget_area_center_Span", "Center + Span"),
		__txtx("widget_area_padding",     "Padding"),
		__txtx("widget_area_two_points",  "Two points"),
	]);
	
	onModifySingle[0] = function(val) {
		var v = toNumber(val);
		var m = onModify(v, 0);
		
		if(mode == AREA_MODE.area || mode == AREA_MODE.two_point || !link_value) 
			return m;
		
		m = onModify(v, 1) || m;
		m = onModify(v, 2) || m;
		m = onModify(v, 3) || m;
		
		return m;
	}
	
	onModifySingle[1] = function(val) {
		var v = toNumber(val);
		var m = onModify(v, 1);
		
		if(mode == AREA_MODE.area || mode == AREA_MODE.two_point || !link_value) 
			return m;
		
		m = onModify(v, 0) || m;
		m = onModify(v, 2) || m;
		m = onModify(v, 3) || m;
		
		return m;
	}
	
	onModifySingle[2] = function(val) {
		var v = toNumber(val);
		var m = onModify(v, 2);
		
		if(mode == AREA_MODE.area || mode == AREA_MODE.two_point || !link_value) 
			return m;
		
		m = onModify(v, 0) || m;
		m = onModify(v, 1) || m;
		m = onModify(v, 3) || m;
		
		return m;
	}
	
	onModifySingle[3] = function(val) {
		var v = toNumber(val);
		var m = onModify(v, 3);
		
		if(mode == AREA_MODE.area || mode == AREA_MODE.two_point || !link_value) 
			return m;
		
		m = onModify(v, 0) || m;
		m = onModify(v, 1) || m;
		m = onModify(v, 2) || m;
		
		return m;
	}
	
	for(var i = 0; i < 4; i++) {
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		tb[i].slidable = true;
		tb[i].hide     = true;
	}
	
	static setInteract = function(interactable = noone) {
		self.interactable = interactable;
		for(var i = 0; i < 4; i++) 
			tb[i].interactable = interactable;
	}
	
	static register = function(parent = noone) {
		switch(mode) {
			case AREA_MODE.two_point :
			case AREA_MODE.area :	   
				for(var i = 0; i < 4; i++) 
					tb[i].register(parent);
				break;
			case AREA_MODE.padding : 
				tb[1].register(parent);
				tb[2].register(parent);
				tb[0].register(parent);
				tb[3].register(parent);
				break;
		}
		
		if(unit != noone && unit.reference != noone)
			unit.triggerButton.register(parent);
	}
	
	static isHovering = function() {
		for( var i = 0, n = array_length(tb); i < n; i++ ) if(tb[i].isHovering()) return true;
		return false;
	}
	
	static setMode = function(_data, _mode) {
		var x0 = 0, y0 = 0;
		var x1 = 0, y1 = 0;
		var ss = unit.mode == VALUE_UNIT.reference? [ 1, 1 ] : onSurfaceSize();

		switch(mode) {
			case AREA_MODE.area :
				var cx = array_safe_get_fast(_data, 0);
				var cy = array_safe_get_fast(_data, 1);
				var sw = array_safe_get_fast(_data, 2);
				var sh = array_safe_get_fast(_data, 3);
				
				x0 = cx - sw;
				y0 = cy - sh;
				x1 = cx + sw;
				y1 = cy + sh;
				break;
				
			case AREA_MODE.padding :
				var r = array_safe_get_fast(_data, 0);
				var t = array_safe_get_fast(_data, 1);
				var l = array_safe_get_fast(_data, 2);
				var b = array_safe_get_fast(_data, 3);
				
				x0 = l;
				y0 = t;
				x1 = ss[0] - r;
				y1 = ss[1] - b;
				break;
				
			case AREA_MODE.two_point :
				x0 = array_safe_get_fast(_data, 0);
				y0 = array_safe_get_fast(_data, 1);
				x1 = array_safe_get_fast(_data, 2);
				y1 = array_safe_get_fast(_data, 3);
				break;
		}
		
		switch(_mode) {
			case AREA_MODE.area :
				onModify((x0 + x1) / 2, 0);
				onModify((y0 + y1) / 2, 1);
				onModify((x1 - x0) / 2, 2);
				onModify((y1 - y0) / 2, 3);
				break;
				
			case AREA_MODE.padding :
				onModify(ss[0] - x1, 0);
				onModify(y0,         1);
				onModify(x0,         2);
				onModify(ss[1] - y1, 3);
				break;
				
			case AREA_MODE.two_point :
				onModify(x0, 0);
				onModify(y0, 1);
				onModify(x1, 2);
				onModify(y1, 3);
				break;
		}
		
		onModify(_mode, 5);
		return _mode;
	}
	
	static fetchHeight = function(params) { return params.h * 2; }
	static drawParam   = function(params) {
		setParam(params);
		for(var i = 0; i < 4; i++) tb[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m);
	}
	
	static draw = function(_x, _y, _w, _h, _data, _display_data, _m) { 
		x = _x;
		y = _y;
		w = _w;
		h = _h * 2;
		mode = array_safe_get_fast(_data, 5);
		
		onSurfaceSize = struct_try_get(_display_data, "onSurfaceSize", -1);
		useShape      = struct_try_get(_display_data, "useShape", true);
		
		var _bs = min(_h, ui(32));
		var _bx   = _x;
		var _by   = _y + _h / 2 - _bs / 2;
		var _bact = adjust_shape && active;
		var _bhov = adjust_shape && hover;
		var _bind = array_safe_get_fast(_data, 4);
		  
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, x, y, w, h, boxColor, 1);
		  
		if(_w - _bs > ui(100) && onSurfaceSize != -1) {
			tooltip.index = mode;
			
			var _bx = _x + _w - _bs;
			if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, _bx, _y, _bs, h, CDEF.main_mdwhite, 1);
			
			if(unit != noone && unit.reference != noone) {
				var _by = _y + h / 2 - _bs / 2;
				unit.triggerButton.setFocusHover(iactive, ihover);
				unit.draw(_bx, _by, _bs, _bs, _m);
				
				_w -= _bs + ui(4);
			}
		
			var _by = _y + _h / 2 - _bs / 2;
			var b = buttonInstant_Pad(THEME.button_hide_fill, _bx, _by, _bs, _bs, _m, hover, active, tooltip, THEME.inspector_area_type, mode);
			if(b == 1) {
				if(key_mod_press(SHIFT) && MOUSE_WHEEL > 0) mode = setMode(_data, (mode - 1 + 3) % 3);
				if(key_mod_press(SHIFT) && MOUSE_WHEEL < 0) mode = setMode(_data, (mode + 1)     % 3);
			}
			if(b == 2) mode = setMode(_data, (mode + 1) % 3);
			
			var _by   = _y + _h + _h / 2 - _bs / 2;
			var _btxt = __txtx("widget_area_fill_surface", "Fill surface");
			
			if(buttonInstant_Pad(THEME.button_hide_fill, _bx, _by, _bs, _bs, _m, hover, active, _btxt, THEME.fill) == 2) { 
				var cnvt = unit != noone && unit.mode == VALUE_UNIT.reference;
				
				switch(mode) {
					case AREA_MODE.area :
						var ss = onSurfaceSize();
						onModify(cnvt? 0.5 : ss[0] / 2, 0);
						onModify(cnvt? 0.5 : ss[1] / 2, 1);
						onModify(cnvt? 0.5 : ss[0] / 2, 2);
						onModify(cnvt? 0.5 : ss[1] / 2, 3);
						break;
						
					case AREA_MODE.padding :   
						var ss = onSurfaceSize();
						onModify(0, 0);
						onModify(0, 1);
						onModify(0, 2);
						onModify(0, 3);
						break;
						
					case AREA_MODE.two_point : 
						var ss = onSurfaceSize();
						onModify(0,               0);
						onModify(0,               1);
						onModify(cnvt? 1 : ss[0], 2);
						onModify(cnvt? 1 : ss[1], 3);
						break;
				}
			} 
			
			_w -= _bs + ui(4);
		} 
		
		if(_w - _bs > ui(100)) { 
			var _bx = _x;
			var _by = _y + _h / 2 - _bs / 2;
			
			if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 3, _bx, _y, _bs, h, CDEF.main_mdwhite, 1);
			
			if(useShape && !is_array(_bind))	
			if(buttonInstant_Pad(THEME.button_hide_fill, _bx, _by, _bs, _bs, _m, _bhov, _bact,, THEME.inspector_area, _bind) == 2) {
				var val = (array_safe_get_fast(_data, 4) + 1) % 2;
				onModify(val, 4);
			}
		  
			if(mode == AREA_MODE.padding) {
				var cc    = link_value? COLORS._main_accent : COLORS._main_icon;
				var _btxt = __txt("Link values");
				var _bby  = useShape? _by + _h : _y + h / 2 - _bs / 2;
			
				if(buttonInstant_Pad(THEME.button_hide_fill, _bx, _bby, _bs, _bs, _m, hover, active, _btxt, THEME.value_link, link_value, cc) == 2)
					link_value = !link_value;
			}
			
			if(useShape || mode == AREA_MODE.padding) {
				_w -= _bs + ui(4);
				_x += _bs + ui(4);
			}
			
		} 
		
		if(hide == 0) draw_sprite_stretched_ext(THEME.textbox, 0, x, y, w, h, boxColor, 0.5 + 0.5 * interactable);	
		
		for(var i = 0; i < 4; i++)
			tb[i].setFocusHover(active, hover);
		
		current_data = _data;
		
		var tb_w = _w / 2;
		var tb_h = _h;
			
		if(mode == AREA_MODE.area) { 
			var tb_x0 = _x;
			var tb_y0 = _y;
			
			var tb_x1 = _x + tb_w;
			var tb_y1 = _y + _h;
			
			tb[0].label = "x";
			tb[1].label = "y";
						  
			tb[2].label = "w";
			tb[3].label = "h";
			
			tb[0].draw(tb_x0, tb_y0, tb_w, tb_h, array_safe_get_fast(_data, 0), _m);
			tb[1].draw(tb_x1, tb_y0, tb_w, tb_h, array_safe_get_fast(_data, 1), _m);
		
			tb[2].draw(tb_x0, tb_y1, tb_w, tb_h, array_safe_get_fast(_data, 2), _m);
			tb[3].draw(tb_x1, tb_y1, tb_w, tb_h, array_safe_get_fast(_data, 3), _m);
		
		
		} else if(mode == AREA_MODE.padding) { 
			var tb_lx = _x;
			var tb_ly = _y;
			
			var tb_rx = _x + tb_w;
			var tb_ry = _y;
			
			var tb_tx = _x;
			var tb_ty = _y + _h;
			
			var tb_bx = _x + tb_w;
			var tb_by = _y + _h;
			
			tb[2].label = "l";
			tb[0].label = "r";
						   
			tb[1].label = "t";
			tb[3].label = "b";
			
			tb[2].draw(tb_lx, tb_ly, tb_w, tb_h, array_safe_get_fast(_data, 2), _m);
			tb[0].draw(tb_rx, tb_ry, tb_w, tb_h, array_safe_get_fast(_data, 0), _m);
			
			tb[1].draw(tb_tx, tb_ty, tb_w, tb_h, array_safe_get_fast(_data, 1), _m);
			tb[3].draw(tb_bx, tb_by, tb_w, tb_h, array_safe_get_fast(_data, 3), _m);
		
		
		} else if(mode == AREA_MODE.two_point) { 
			var tb_x0 = _x;
			var tb_y0 = _y;
			
			var tb_x1 = _x + tb_w;
			var tb_y1 = _y + _h;
			
			tb[0].label = "x0";
			tb[1].label = "y0";
						   
			tb[2].label = "x1";
			tb[3].label = "y1";
			
			tb[0].draw(tb_x0, tb_y0, tb_w, tb_h, array_safe_get_fast(_data, 0), _m);
			tb[1].draw(tb_x1, tb_y0, tb_w, tb_h, array_safe_get_fast(_data, 1), _m);
		
			tb[2].draw(tb_x0, tb_y1, tb_w, tb_h, array_safe_get_fast(_data, 2), _m);
			tb[3].draw(tb_x1, tb_y1, tb_w, tb_h, array_safe_get_fast(_data, 3), _m);
		
		}
		
		resetFocus();
		
		return h;
	} 
	
	static clone = function() { 
		var cln = new areaBox(onModify, unit);
		
		return cln;
	} 

	static free = function() {
		for( var i = 0, n = array_length(tb); i < n; i++ ) tb[i].free();
	}
}