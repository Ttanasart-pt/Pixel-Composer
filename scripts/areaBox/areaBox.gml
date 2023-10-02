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
	half_h
}

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
		
		if(mode == AREA_MODE.area) {
			return onModify(0, v); 
		} else if(mode == AREA_MODE.padding) {
			if(link_value)	return onModify(0, v) || onModify(1, v) || onModify(2, v) || onModify(3, v);
			else			return onModify(0, v); 
		} else if(mode == AREA_MODE.two_point) {
			return onModify(0, v);
		}
	} #endregion
	onModifySingle[1] = function(val) { #region
		var v = toNumber(val);
		
		if(mode == AREA_MODE.area) {
			return onModify(1, v); 
		} else if(mode == AREA_MODE.padding) {
			if(link_value)	return onModify(0, v) || onModify(1, v) || onModify(2, v) || onModify(3, v);
			else			return onModify(1, v); 
		} else if(mode == AREA_MODE.two_point) {
			return onModify(1, v);
		}
	} #endregion
	onModifySingle[2] = function(val) { #region
		var v = toNumber(val);
		
		if(mode == AREA_MODE.area) {
			return onModify(2, v); 
		} else if(mode == AREA_MODE.padding) {
			if(link_value)	return onModify(0, v) || onModify(1, v) || onModify(2, v) || onModify(3, v);
			else			return onModify(2, v); 
		} else if(mode == AREA_MODE.two_point) {
			return onModify(2, v);
		}
	} #endregion
	onModifySingle[3] = function(val) { #region
		var v = toNumber(val);
		
		if(mode == AREA_MODE.area) {
			return onModify(3, v); 
		} else if(mode == AREA_MODE.padding) {
			if(link_value)	return onModify(0, v) || onModify(1, v) || onModify(2, v) || onModify(3, v);
			else			return onModify(3, v); 
		} else if(mode == AREA_MODE.two_point) {
			return onModify(3, v);
		}
	} #endregion
	
	for(var i = 0; i < 4; i++) { #region
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		tb[i].slidable = true;
	} #endregion
	
	static setSlideSpeed = function(speed) { #region
		for(var i = 0; i < 4; i++)
			tb[i].slide_speed = speed;
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
	
	static drawParam = function(params) { #region
		return draw(params.x + params.w / 2, params.y + ui(40), params.data, params.display_data, params.m);
	} #endregion
	
	static draw = function(_x, _y, _data, _display_data, _m) {
		x = _x;
		y = _y;
		w = 0;
		h = ui(204);
		mode = _display_data.area_type;
		
		var _bx   = _x - ui(48);
		var _by   = _y + ui(64 - 48);
		var _bs   = ui(96);
		var _bact = adjust_shape && active;
		var _bhov = adjust_shape && hover;
		var _bind = array_safe_get(_data, 4);
		
		if(!is_array(_bind))
		if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, _m, _bact, _bhov,, THEME.inspector_area, _bind, c_white) == 2) {
			var val = (array_safe_get(_data, 4) + 1) % 2;
			onModify(4, val);
		}
		
		if(onSurfaceSize != -1) {
			var _bx   = _x - ui(76);
			var _by   = _y + ui(28 - 12);
			var _bs   = ui(24);
			var _btxt = __txtx("widget_area_fill_surface", "Full surface");
			
			if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, _m, active, hover, _btxt, THEME.fill, 0, c_white) == 2) { #region
				switch(mode) {
					case AREA_MODE.area :
						var ss = onSurfaceSize();
						onModify(0, ss[0] / 2);
						onModify(1, ss[1] / 2);
						onModify(2, ss[0] / 2);
						onModify(3, ss[1] / 2);
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
						onModify(2, ss[0]);
						onModify(3, ss[1]);
						break;
				}
			} #endregion
			
			tooltip.index = mode;
			
			var _bx = _x + ui(76 - 24);
			var _by = _y + ui(28 - 12);
			var _bs = ui(24);
			
			if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, _m, active, hover, tooltip, THEME.inspector_area_type, mode, c_white) == 2) { #region
				switch(mode) {
					case AREA_MODE.area : //area to padding
						var cx = array_safe_get(_data, 0);
						var cy = array_safe_get(_data, 1);
						var sw = array_safe_get(_data, 2);
						var sh = array_safe_get(_data, 3);
						var ss = onSurfaceSize();
						
						onModify(0, ss[0] - (cx + sw));
						onModify(1, cy - sh);
						onModify(2, cx - sw);
						onModify(3, ss[1] - (cy + sh));
						break;
						
					case AREA_MODE.padding : //padding to two points
						var r = array_safe_get(_data, 0);
						var t = array_safe_get(_data, 1);
						var l = array_safe_get(_data, 2);
						var b = array_safe_get(_data, 3);
						var ss = onSurfaceSize();
						
						onModify(0, l);
						onModify(1, t);
						onModify(2, ss[0] - r);
						onModify(3, ss[1] - b);
						break;
						
					case AREA_MODE.two_point : //twp points to area
						var x0 = array_safe_get(_data, 0);
						var y0 = array_safe_get(_data, 1);
						var x1 = array_safe_get(_data, 2);
						var y1 = array_safe_get(_data, 3);
						
						onModify(0, (x0 + x1) / 2);
						onModify(1, (y0 + y1) / 2);
						onModify(2, abs(x0 - x1) / 2);
						onModify(3, abs(y0 - y1) / 2);
						break;
				}
				
				_display_data.area_type = (mode + 1) % 3;
			} #endregion
		} 
		
		if(mode == AREA_MODE.padding) { #region
			var cc    = link_value? COLORS._main_accent : COLORS._main_icon;
			var _bx   = _x - ui(76);
			var _by   = _y + ui(88);
			var _bs   = ui(24);
			var _btxt = __txt("Link values");
			
			if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, _m, active, hover, _btxt, THEME.value_link, link_value, cc) == 2)
				link_value = !link_value;
		} #endregion
		
		for(var i = 0; i < 4; i++) {
			tb[i].setFocusHover(active, hover);
			tb[i].align  = fa_center;
		}
		
		current_data = _data;
		
		if(mode == AREA_MODE.area) { #region
			var tb_x0 = _x + ui(6) - ui(64) - ui(48);
			var tb_x1 = _x + ui(6) + ui(64) - ui(48);
			var tb_y0 = _y - ui(28);
			var tb_y1 = _y + ui(64 + 48 + 8);
		
			draw_set_text(f_p0, fa_right, fa_center, COLORS._main_text_sub);
			
			draw_text(tb_x0 - ui(4), tb_y0 + TEXTBOX_HEIGHT / 2, "x");
			draw_text(tb_x1 - ui(4), tb_y0 + TEXTBOX_HEIGHT / 2, "y");
		
			draw_text(tb_x0 - ui(4), tb_y1 + TEXTBOX_HEIGHT / 2, "w");
			draw_text(tb_x1 - ui(4), tb_y1 + TEXTBOX_HEIGHT / 2, "h");
		
			tb[0].draw(tb_x0, tb_y0, ui(96), TEXTBOX_HEIGHT, array_safe_get(_data, 0), _m);
			tb[1].draw(tb_x1, tb_y0, ui(96), TEXTBOX_HEIGHT, array_safe_get(_data, 1), _m);
		
			tb[2].draw(tb_x0, tb_y1, ui(96), TEXTBOX_HEIGHT, array_safe_get(_data, 2), _m);
			tb[3].draw(tb_x1, tb_y1, ui(96), TEXTBOX_HEIGHT, array_safe_get(_data, 3), _m);
		#endregion
		} else if(mode == AREA_MODE.padding) { #region
			var tb_rx = _x + ui(56);
			var tb_ry = _y + ui(48);
			
			var tb_tx = _x - ui(48);
			var tb_ty = _y - ui(28);
			
			var tb_lx = _x - ui(56 + 96);
			var tb_ly = _y + ui(48);
			
			var tb_bx = _x - ui(48);
			var tb_by = _y + ui(64 + 48 + 8);
			
			tb[0].draw(tb_rx, tb_ry, ui(96), TEXTBOX_HEIGHT, array_safe_get(_data, 0), _m);
			tb[1].draw(tb_tx, tb_ty, ui(96), TEXTBOX_HEIGHT, array_safe_get(_data, 1), _m);
															 
			tb[2].draw(tb_lx, tb_ly, ui(96), TEXTBOX_HEIGHT, array_safe_get(_data, 2), _m);
			tb[3].draw(tb_bx, tb_by, ui(96), TEXTBOX_HEIGHT, array_safe_get(_data, 3), _m);
		#endregion
		} else if(mode == AREA_MODE.two_point) { #region
			var tb_x0 = _x + ui(6) - ui(64) - ui(48);
			var tb_x1 = _x + ui(6) + ui(64) - ui(48);
			var tb_y0 = _y - ui(28);
			var tb_y1 = _y + ui(64 + 48 + 8);
		
			draw_set_text(f_p0, fa_right, fa_center, COLORS._main_text_sub);
			
			draw_text(tb_x0 - ui(4), tb_y0 + TEXTBOX_HEIGHT / 2, "x0");
			draw_text(tb_x1 - ui(4), tb_y0 + TEXTBOX_HEIGHT / 2, "y0");
		
			draw_text(tb_x0 - ui(4), tb_y1 + TEXTBOX_HEIGHT / 2, "x1");
			draw_text(tb_x1 - ui(4), tb_y1 + TEXTBOX_HEIGHT / 2, "y1");
			
			tb[0].draw(tb_x0, tb_y0, ui(96), TEXTBOX_HEIGHT, array_safe_get(_data, 0), _m);
			tb[1].draw(tb_x1, tb_y0, ui(96), TEXTBOX_HEIGHT, array_safe_get(_data, 1), _m);
															 
			tb[2].draw(tb_x0, tb_y1, ui(96), TEXTBOX_HEIGHT, array_safe_get(_data, 2), _m);
			tb[3].draw(tb_x1, tb_y1, ui(96), TEXTBOX_HEIGHT, array_safe_get(_data, 3), _m);
		#endregion
		}
			
		if(unit != noone && unit.reference != noone) {
			unit.triggerButton.setFocusHover(active, hover);
			unit.draw(_x + ui(56 + 48 + 8), _y - ui(28), ui(32), ui(32), _m);
		}
		
		resetFocus();
		
		return h;
	}
}