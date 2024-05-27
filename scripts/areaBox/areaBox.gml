enum AREA_SHAPE {
	rectangle,
	elipse
}

enum AREA_MODE {
	area,
	padding,
	two_point,
}

enum AREA_INDEX {
	center_x,
	center_y,
	half_w,
	half_h,
	shape
}

#macro DEF_AREA [ DEF_SURF_W / 2, DEF_SURF_H / 2, DEF_SURF_W / 2, DEF_SURF_H / 2, AREA_SHAPE.rectangle, AREA_MODE.area ]
#macro DEF_AREA_REF [ 0.5, 0.5, 0.5, 0.5, AREA_SHAPE.rectangle, AREA_MODE.area ]

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
	
	onModifySingle[0] = function(val) { #region
		var v = toNumber(val);
		var m = onModify(0, v);
		
		if(mode == AREA_MODE.area || mode == AREA_MODE.two_point || !link_value) 
			return m;
		
		m |= onModify(1, v);
		m |= onModify(2, v);
		m |= onModify(3, v);
		
		return m;
	} #endregion
	
	onModifySingle[1] = function(val) { #region
		var v = toNumber(val);
		var m = onModify(1, v);
		
		if(mode == AREA_MODE.area || mode == AREA_MODE.two_point || !link_value) 
			return m;
		
		m |= onModify(0, v);
		m |= onModify(2, v);
		m |= onModify(3, v);
		
		return m;
	} #endregion
	
	onModifySingle[2] = function(val) { #region
		var v = toNumber(val);
		var m = onModify(2, v);
		
		if(mode == AREA_MODE.area || mode == AREA_MODE.two_point || !link_value) 
			return m;
		
		m |= onModify(0, v);
		m |= onModify(1, v);
		m |= onModify(3, v);
		
		return m;
	} #endregion
	
	onModifySingle[3] = function(val) { #region
		var v = toNumber(val);
		var m = onModify(3, v);
		
		if(mode == AREA_MODE.area || mode == AREA_MODE.two_point || !link_value) 
			return m;
		
		m |= onModify(0, v);
		m |= onModify(1, v);
		m |= onModify(2, v);
		
		return m;
	} #endregion
	
	for(var i = 0; i < 4; i++) { #region
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		tb[i].slidable = true;
		tb[i].hide     = true;
	} #endregion
	
	static setSlideSpeed = function(speed) { #region
		for(var i = 0; i < 4; i++)
			tb[i].setSlidable(speed);
	} #endregion
	
	static setInteract = function(interactable = noone) { #region
		self.interactable = interactable;
		for(var i = 0; i < 4; i++) 
			tb[i].interactable = interactable;
	} #endregion
	
	static register = function(parent = noone) { #region
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
	} #endregion
	
	static isHovering = function() { #region
		for( var i = 0, n = array_length(tb); i < n; i++ ) if(tb[i].isHovering()) return true;
		return false;
	} #endregion
	
	static drawParam = function(params) { #region
		setParam(params);
		for(var i = 0; i < 4; i++) tb[i].setParam(params);
		
		return draw(params.x, params.y, params.w, params.h, params.data, params.display_data, params.m);
	} #endregion
	
	static draw = function(_x, _y, _w, _h, _data, _display_data, _m) { #region
		x = _x;
		y = _y;
		w = _w;
		h = _h * 2 + ui(4);
		mode = array_safe_get_fast(_data, 5);
		
		onSurfaceSize = struct_try_get(_display_data, "onSurfaceSize", -1);
		useShape      = struct_try_get(_display_data, "useShape", true);
		
		var _bs = min(_h, ui(32));
		var _bx   = _x;
		var _by   = _y + _h / 2 - _bs / 2;
		var _bact = adjust_shape && active;
		var _bhov = adjust_shape && hover;
		var _bind = array_safe_get_fast(_data, 4);
		  
		if(_w - _bs > ui(100) && onSurfaceSize != -1) {
			tooltip.index = mode;
			
			if(unit != noone && unit.reference != noone) {
				var _bx   = _x + _w - _bs;
				var _by   = _y + h / 2 - _bs / 2;
			
				unit.triggerButton.setFocusHover(active, hover);
				unit.draw(_bx, _by, _bs, _bs, _m);
				
				_w -= _bs + ui(4);
			}
		
			var _bx   = _x + _w - _bs;
			var _by   = _y + _h / 2 - _bs / 2;
			
			if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, _m, active, hover, tooltip, THEME.inspector_area_type, mode) == 2) { #region
				switch(mode) {
					case AREA_MODE.area : //area to padding
						var cx = array_safe_get_fast(_data, 0);
						var cy = array_safe_get_fast(_data, 1);
						var sw = array_safe_get_fast(_data, 2);
						var sh = array_safe_get_fast(_data, 3);
						var ss = unit.mode == VALUE_UNIT.reference? [ 1, 1 ] : onSurfaceSize();
						
						onModify(0, ss[0] - (cx + sw));
						onModify(1, cy - sh);
						onModify(2, cx - sw);
						onModify(3, ss[1] - (cy + sh));
						break;
						
					case AREA_MODE.padding : //padding to two points
						var r  = array_safe_get_fast(_data, 0);
						var t  = array_safe_get_fast(_data, 1);
						var l  = array_safe_get_fast(_data, 2);
						var b  = array_safe_get_fast(_data, 3);
						var ss = unit.mode == VALUE_UNIT.reference? [ 1, 1 ] : onSurfaceSize();
						
						onModify(0, l);
						onModify(1, t);
						onModify(2, ss[0] - r);
						onModify(3, ss[1] - b);
						break;
						
					case AREA_MODE.two_point : //twp points to area
						var x0 = array_safe_get_fast(_data, 0);
						var y0 = array_safe_get_fast(_data, 1);
						var x1 = array_safe_get_fast(_data, 2);
						var y1 = array_safe_get_fast(_data, 3);
						
						onModify(0, (x0 + x1) / 2);
						onModify(1, (y0 + y1) / 2);
						onModify(2, abs(x0 - x1) / 2);
						onModify(3, abs(y0 - y1) / 2);
						break;
				}
				
				onModify(5, (mode + 1) % 3);
			} #endregion
			
			var _bx   = _x + _w - _bs;
			var _by   = _y + _h + ui(4) + _h / 2 - _bs / 2;
			var _btxt = __txtx("widget_area_fill_surface", "Fill surface");
			
			if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, _m, active, hover, _btxt, THEME.fill, 0) == 2) { #region
				var cnvt = unit != noone && unit.mode == VALUE_UNIT.reference;
				
				switch(mode) {
					case AREA_MODE.area :
						var ss = onSurfaceSize();
						onModify(0, cnvt? 0.5 : ss[0] / 2);
						onModify(1, cnvt? 0.5 : ss[1] / 2);
						onModify(2, cnvt? 0.5 : ss[0] / 2);
						onModify(3, cnvt? 0.5 : ss[1] / 2);
						break;
					case AREA_MODE.padding :   
						var ss = onSurfaceSize();
						onModify(0, 0);
						onModify(1, 0);
						onModify(2, 0);
						onModify(3, 0);
						break;
					case AREA_MODE.two_point : 
						var ss = onSurfaceSize();
						onModify(0, 0);
						onModify(1, 0);
						onModify(2, cnvt? 1 : ss[0]);
						onModify(3, cnvt? 1 : ss[1]);
						break;
				}
			} #endregion
			
			_w -= _bs + ui(4);
		} 
		
		if(_w - _bs > ui(100)) { #region
			var _bx   = _x;
			var _by   = _y + _h / 2 - _bs / 2;
				
			if(useShape && !is_array(_bind) && buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, _m, _bact, _bhov,, THEME.inspector_area, _bind) == 2) {
				var val = (array_safe_get_fast(_data, 4) + 1) % 2;
				onModify(4, val);
			}
		  
			if(mode == AREA_MODE.padding) {
				var cc    = link_value? COLORS._main_accent : COLORS._main_icon;
				var _btxt = __txt("Link values");
				var _bby  = useShape? _by + _h + ui(4) : _y + h / 2 - _bs / 2;
			
				if(buttonInstant(THEME.button_hide, _bx, _bby, _bs, _bs, _m, active, hover, _btxt, THEME.value_link, link_value, cc) == 2)
					link_value = !link_value;
			}
			
			if(useShape || mode == AREA_MODE.padding) {
				_w -= _bs + ui(4);
				_x +=_bs + ui(4);
			}
			
		} #endregion
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y, _w, _h, c_white, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y, _w, _h, c_white, 0.5 + 0.5 * interactable);	
		
		draw_sprite_stretched_ext(THEME.textbox, 3, _x, _y + _h + ui(4), _w, _h, c_white, 1);
		draw_sprite_stretched_ext(THEME.textbox, 0, _x, _y + _h + ui(4), _w, _h, c_white, 0.5 + 0.5 * interactable);	
		
		for(var i = 0; i < 4; i++)
			tb[i].setFocusHover(active, hover);
		
		current_data = _data;
		
		var tb_w = _w / 2;
		var tb_h = _h;
			
		if(mode == AREA_MODE.area) { #region
			var tb_x0 = _x;
			var tb_y0 = _y;
			
			var tb_x1 = _x + tb_w;
			var tb_y1 = _y + _h + ui(4);
			
			tb[0].label = "x";
			tb[1].label = "y";
						  
			tb[2].label = "w";
			tb[3].label = "h";
			
			tb[0].draw(tb_x0, tb_y0, tb_w, tb_h, array_safe_get_fast(_data, 0), _m);
			tb[1].draw(tb_x1, tb_y0, tb_w, tb_h, array_safe_get_fast(_data, 1), _m);
		
			tb[2].draw(tb_x0, tb_y1, tb_w, tb_h, array_safe_get_fast(_data, 2), _m);
			tb[3].draw(tb_x1, tb_y1, tb_w, tb_h, array_safe_get_fast(_data, 3), _m);
		#endregion
		
		} else if(mode == AREA_MODE.padding) { #region
			var tb_lx = _x;
			var tb_ly = _y;
			
			var tb_rx = _x + tb_w;
			var tb_ry = _y;
			
			var tb_tx = _x;
			var tb_ty = _y + _h + ui(4);
			
			var tb_bx = _x + tb_w;
			var tb_by = _y + _h + ui(4);
			
			tb[2].label = "l";
			tb[0].label = "r";
						   
			tb[1].label = "t";
			tb[3].label = "b";
			
			tb[2].draw(tb_lx, tb_ly, tb_w, tb_h, array_safe_get_fast(_data, 2), _m);
			tb[0].draw(tb_rx, tb_ry, tb_w, tb_h, array_safe_get_fast(_data, 0), _m);
			
			tb[1].draw(tb_tx, tb_ty, tb_w, tb_h, array_safe_get_fast(_data, 1), _m);
			tb[3].draw(tb_bx, tb_by, tb_w, tb_h, array_safe_get_fast(_data, 3), _m);
		#endregion
		
		} else if(mode == AREA_MODE.two_point) { #region
			var tb_x0 = _x;
			var tb_y0 = _y;
			
			var tb_x1 = _x + tb_w;
			var tb_y1 = _y + _h + ui(4);
			
			tb[0].label = "x0";
			tb[1].label = "y0";
						   
			tb[2].label = "x1";
			tb[3].label = "y1";
			
			tb[0].draw(tb_x0, tb_y0, tb_w, tb_h, array_safe_get_fast(_data, 0), _m);
			tb[1].draw(tb_x1, tb_y0, tb_w, tb_h, array_safe_get_fast(_data, 1), _m);
		
			tb[2].draw(tb_x0, tb_y1, tb_w, tb_h, array_safe_get_fast(_data, 2), _m);
			tb[3].draw(tb_x1, tb_y1, tb_w, tb_h, array_safe_get_fast(_data, 3), _m);
		#endregion
		}
		
		resetFocus();
		
		return h;
	} #endregion
	
	static clone = function() { #region
		var cln = new areaBox(onModify, unit);
		
		return cln;
	} #endregion
}