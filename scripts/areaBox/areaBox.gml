enum AREA_SHAPE {
	rectangle,
	elipse
}

enum AREA_MODE {
	area,
	padding,
	two_point,
}

function areaBox(_onModify, _unit = noone) : widget() constructor {
	onModify = _onModify;
	unit	 = _unit;
	onSurfaceSize = -1;
	
	link_value = false;
	current_data = [ 0, 0, 0, 0 ];
	adjust_shape = true;
	mode = AREA_MODE.area;
	
	onModifySingle[0] = function(val) { 
		if(mode == AREA_MODE.area) {
			return onModify(0, toNumber(val)); 
		} else if(mode == AREA_MODE.padding) {
			var v = toNumber(val);
			if(link_value)	current_data = [ v, v, v, v ];
			else			current_data[0] = v;
			return setAllData(current_data);
		} else if(mode == AREA_MODE.two_point) {
			return onModify(0, val);
		}
	}
	
	onModifySingle[1] = function(val) { 
		if(mode == AREA_MODE.area) {
			return onModify(1, toNumber(val)); 
		} else if(mode == AREA_MODE.padding) {
			var v = toNumber(val);
			if(link_value)	current_data = [ v, v, v, v ];
			else			current_data[1] = v;
			return setAllData(current_data);
		} else if(mode == AREA_MODE.two_point) {
			return onModify(1, val);
		}
	}
	
	onModifySingle[2] = function(val) { 
		if(mode == AREA_MODE.area) {
			return onModify(2, toNumber(val)); 
		} else if(mode == AREA_MODE.padding) {
			var v = toNumber(val);
			if(link_value)	current_data = [ v, v, v, v ];
			else			current_data[2] = v;
			return setAllData(current_data);
		} else if(mode == AREA_MODE.two_point) {
			return onModify(2, val);
		}
	}
	
	onModifySingle[3] = function(val) { 
		if(mode == AREA_MODE.area) {
			return onModify(3, toNumber(val)); 
		} else if(mode == AREA_MODE.padding) {
			var v = toNumber(val);
			if(link_value)	current_data = [ v, v, v, v ];
			else			current_data[3] = v;
			return setAllData(current_data);
		} else if(mode == AREA_MODE.two_point) {
			return onModify(3, val);
		}
	}
	
	for(var i = 0; i < 4; i++) {
		tb[i] = new textBox(TEXTBOX_INPUT.number, onModifySingle[i]);
		tb[i].slidable = true;
	}
	
	static setSlideSpeed = function(speed) {
		for(var i = 0; i < 4; i++)
			tb[i].slide_speed = speed;
	}
	
	static setAllData = function(data) {
		var mod0 = onModify(0, data[0]);
		var mod1 = onModify(1, data[1]);
		var mod2 = onModify(2, data[2]);
		var mod3 = onModify(3, data[3]);
		
		return mod0 || mod1 || mod2 || mod3;
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
	
	static draw = function(_x, _y, _data, _extra_data, _m) {
		x = _x;
		y = _y;
		w = 0;
		h = ui(204);
		mode = ds_list_get(_extra_data, 0);
		
		if(buttonInstant(THEME.button_hide, _x - ui(48), _y + ui(64 - 48), ui(96), ui(96), _m, adjust_shape && active, adjust_shape && hover, 
			"", THEME.inspector_area, array_safe_get(_data, 4), c_white) == 2) {
			
			if(mouse_press(mb_left, active)) {
				var val = (array_safe_get(_data, 4) + 1) % 2;
				onModify(4, val);
			}
		}
		
		if(onSurfaceSize != -1) {
			if(buttonInstant(THEME.button_hide, _x - ui(76), _y + ui(28 - 12), ui(24), ui(24), _m, active, hover, "Fill surface", THEME.fill, 0, c_white) == 2) {
				var ss = onSurfaceSize();
				onModify(0, toNumber(ss[0] / 2));
				onModify(1, toNumber(ss[1] / 2));
				onModify(2, toNumber(ss[0] / 2));
				onModify(3, toNumber(ss[1] / 2));
			}
			
			var txt = "";
			switch(mode) {
				case AREA_MODE.area :	   txt = "Center + Span"; break;
				case AREA_MODE.padding :   txt = "Padding"; break;
				case AREA_MODE.two_point : txt = "Two points"; break;
			}
			
			if(buttonInstant(THEME.button_hide, _x + ui(76 - 24), _y + ui(28 - 12), ui(24), ui(24), _m, active, hover, txt, THEME.inspector_area_type, mode, c_white) == 2) {
				switch(mode) {
					case AREA_MODE.area : 
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
						
					case AREA_MODE.padding :
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
						
					case AREA_MODE.two_point :
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
				
				_extra_data[| 0] = (mode + 1) % 3;
			}
		}
		
		if(mode == AREA_MODE.padding) {
			var cc = link_value? COLORS._main_accent : COLORS._main_icon;
			if(buttonInstant(THEME.button_hide, _x - ui(76), _y + ui(88), ui(24), ui(24), _m, active, hover, "Link value", THEME.value_link, link_value, cc) == 2)
				link_value = !link_value;
		}
		
		for(var i = 0; i < 4; i++) {
			tb[i].hover  = hover;
			tb[i].active = active;
			tb[i].align  = fa_center;
		}
		
		current_data = _data;
		
		if(mode == AREA_MODE.area) {
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
		} else if(mode == AREA_MODE.padding) {
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
		} else if(mode == AREA_MODE.two_point) {
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
		}
			
		if(unit != noone && unit.reference != noone) {
			unit.triggerButton.hover  = ihover;
			unit.triggerButton.active = iactive;
			
			unit.draw(_x + ui(56 + 48 + 8), _y - ui(28), ui(32), ui(32), _m);
		}
		
		resetFocus();
	}
}