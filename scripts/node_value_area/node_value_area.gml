#region global
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
	#macro AREA_ARRAY_LENGTH 6
#endregion

function nodeValue_Area(_name, _value = DEF_AREA, _data = {}) { return new __NodeValue_Area(_name, self, _value, _data); }
function __NodeValue_Area(_name, _node, _value, _data = {}) : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.float, _value, "") constructor {
	setDisplay(VALUE_DISPLAY.area, _data);
	preview_hotkey_spr = THEME.bone_tool_move;
	def_length = AREA_ARRAY_LENGTH;
	
	/////============== GET =============
	
	static valueProcess = function(val, nodeFrom, applyUnit = true, arrIndex = 0) {
		val = array_verify(val, AREA_ARRAY_LENGTH);
		
		if(!is_undefined(nodeFrom) && struct_has(nodeFrom.display_data, "onSurfaceSize")) {
			var surf     = nodeFrom.display_data.onSurfaceSize();
			var dispType = array_safe_get_fast(val, 5, AREA_MODE.area);
			
			switch(dispType) {
				case AREA_MODE.area : break;
				
				case AREA_MODE.padding : 
					var ww = unit.mode == VALUE_UNIT.reference? 1 : surf[0];
					var hh = unit.mode == VALUE_UNIT.reference? 1 : surf[1];
					
					var cx = (ww - val[0] + val[2]) / 2
					var cy = (val[1] + hh - val[3]) / 2;
					var sw = abs((ww - val[0]) - val[2]) / 2;
					var sh = abs(val[1] - (hh - val[3])) / 2;
					
					val = [cx, cy, sw, sh, val[4], val[5]];
					break;
				
				case AREA_MODE.two_point : 
					var cx = (val[0] + val[2]) / 2
					var cy = (val[1] + val[3]) / 2;
					var sw = abs(val[0] - val[2]) / 2;
					var sh = abs(val[1] - val[3]) / 2;
				
					val = [cx, cy, sw, sh, val[4], val[5]];
					break;
			}
		}
		
		return applyUnit? unit.apply(val, arrIndex) : val;
	}
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; 
		
		if(!is(nod, NodeValue)) return val;
		return valueProcess(val, nod, applyUnit, arrIndex);
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		
		if(!getAnim()) {
			if(sep_axis) return array_create_ext(AREA_ARRAY_LENGTH, function(i) /*=>*/ {return animators[i].processType(animators[i].values[0].value)});
			return array_empty(animator.values)? 0 : animator.processType(animator.values[0].value);
		}
		
		if(sep_axis) {
			__temp_time = _time;
			return array_create_ext(AREA_ARRAY_LENGTH, function(i) /*=>*/ {return animators[i].getValue(__temp_time)});
		} 
		
		return animator.getValue(_time);
	}
	
	/////============== DRAW =============
	
	__preview_bbox = noone;
	preview_hotkey_v0 = [ 0, 0 ];
	
	static drawOverlayToggle = function() {
		preview_hotkey_active = true;
		preview_hotkey_step   =  0;
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag = 0b0011) { 
		if(expUse) return -1;
		__preview_bbox = node.__preview_bbox;
		
		var _hovering = preview_hotkey_active;
		
		if(preview_hotkey_active) {
			
			var _vx = (_mx - _x) / _s;
			var _vy = (_my - _y) / _s;
			
			switch(preview_hotkey_step) {
				case 0 : 
					if(mouse_lpress(active)) {
						preview_hotkey_step = 1;
						preview_hotkey_v0   = [ _vx, _vy ];
					}
					
					draw_set_color(COLORS._main_icon);
					draw_line(0, _my, 9999, _my);
					draw_line(_mx, 0, _mx, 9999);
					break;
					
				case 1 : 
					var _cx = (preview_hotkey_v0[0] + _vx) / 2;
					var _cy = (preview_hotkey_v0[1] + _vy) / 2;
					
					var _hw = abs(preview_hotkey_v0[0] - _vx) / 2;
					var _hh = abs(preview_hotkey_v0[1] - _vy) / 2;
					
					var val = getValue();
					val[0] = _cx;
					val[1] = _cy;
					
					val[2] = _hw;
					val[3] = _hh;
					
					if(setValue(val)) UNDO_HOLDING = true;
					
					if(mouse_lrelease()) {
						preview_hotkey_active = false;
						UNDO_HOLDING = false;
					}
					
					draw_set_color(COLORS._main_accent);
					draw_rectangle(_mx, _my, _x + preview_hotkey_v0[0] * _s, _y + preview_hotkey_v0[1] * _s, true);
					break;
			}
			
			if(key_press(vk_enter) || preview_hotkey.isPressing()) {
				preview_hotkey_active = false;
				UNDO_HOLDING = false;
			}
			
		}
		
		if(active && preview_hotkey && preview_hotkey.isPressing()) 
			drawOverlayToggle();
		
		_hovering = _hovering || preview_overlay_area(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag, struct_try_get(display_data, "onSurfaceSize"))
		return _hovering;
	}
	
	static drawOverlayFallOff = function(_x, _y, _s, _fall) {
		var _area = getValue();
		
		var cx = _x + _area[0] * _s;
		var cy = _y + _area[1] * _s;
		var cw = _area[2] * _s;
		var ch = _area[3] * _s;
		var cs = _area[4];
		var ff = _fall * _s / 2;
		
		var x0 = cx - cw + ff;
		var x1 = cx + cw - ff;
		var y0 = cy - ch + ff;
		var y1 = cy + ch - ff;
		
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(0.5);
		switch(cs) {
			case AREA_SHAPE.elipse :	draw_ellipse_dash(cx, cy, cw - ff, ch - ff); break;	
			case AREA_SHAPE.rectangle :	draw_rectangle_dashed(x0, y0, x1, y1);       break;	
		}
		
		var x0 = cx - cw - ff;
		var x1 = cx + cw + ff;
		var y0 = cy - ch - ff;
		var y1 = cy + ch + ff;
		
		switch(cs) {
			case AREA_SHAPE.elipse :	draw_ellipse_dash(cx, cy, cw + ff, ch + ff); break;	
			case AREA_SHAPE.rectangle :	draw_rectangle_dashed(x0, y0, x1, y1);       break;
		}
		draw_set_alpha(1);
	}
}

function area_get_point_influence(_area, _fall, _fallCurve, _x, _y) {
	var area_x = _area[0];
	var area_y = _area[1];
	var area_w = _area[2];
	var area_h = _area[3];
	var area_t = _area[4];
	
	var area_x0 = area_x - area_w;
	var area_x1 = area_x + area_w;
	var area_y0 = area_y - area_h;
	var area_y1 = area_y + area_h;
	
	var _in  = false;
	var _dst = 0;
					
	if(area_t == AREA_SHAPE.rectangle) {
		_in  =    point_in_rectangle(_x, _y, area_x0, area_y0, area_x1, area_y1)
		_dst = min(	distance_to_line(_x, _y, area_x0, area_y0, area_x1, area_y0), 
					distance_to_line(_x, _y, area_x0, area_y1, area_x1, area_y1), 
					distance_to_line(_x, _y, area_x0, area_y0, area_x0, area_y1), 
					distance_to_line(_x, _y, area_x1, area_y0, area_x1, area_y1));
					
	} else if(area_t == AREA_SHAPE.elipse) {
		var _dirr = point_direction(area_x, area_y, _x, _y);
		var _epx = area_x + lengthdir_x(area_w, _dirr);
		var _epy = area_y + lengthdir_y(area_h, _dirr);
		
		_in  = point_distance(area_x, area_y, _x, _y) < point_distance(area_x, area_y, _epx, _epy);
		_dst = point_distance(_x, _y, _epx, _epy);
	}
		
	var str = bool(_in);
	var inf = _in? 0.5 + _dst / _fall : 0.5 - _dst / _fall;
	str = eval_curve_x(_fallCurve, clamp(inf, 0., 1.));
	
	return str;
}
