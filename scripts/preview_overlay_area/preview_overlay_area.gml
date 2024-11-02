function preview_overlay_area_padding(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag, display_data) {
	var _val  = array_clone(getValue());
	var hover = -1;
	
	if(!is_callable(display_data)) return hover;
	
	var __ax = array_safe_get_fast(_val, 0);
	var __ay = array_safe_get_fast(_val, 1);
	var __aw = array_safe_get_fast(_val, 2);
	var __ah = array_safe_get_fast(_val, 3);
	var __at = array_safe_get_fast(_val, 4);
	
	var _x0 = __ax - __aw;
	var _x1 = __ax + __aw;
	var _y0 = __ay - __ah;
	var _y1 = __ay + __ah;
	
	var ss = display_data();
	
	var _l  = _x0;
	var _r  = ss[0] - _x1;
	var _t  = _y0;
	var _b  = ss[1] - _y1;
	var _xc = __ax;
	var _yc = __ay;
	
	var x0 = _l * _s + _x;
	var y0 = _t * _s + _y;
	var x1 = (ss[0] - _r) * _s + _x;
	var y1 = (ss[1] - _b) * _s + _y;
	var xc = (x0 + x1) / 2;
	var yc = (y0 + y1) / 2;
	
	var drawPos  = _flag & 0b0001;
	var drawSize = _flag & 0b0010;
	
	if(drawSize) {
		draw_set_color(COLORS._main_accent);
		draw_set_circle_precision(32);
		switch(__at) {
			case AREA_SHAPE.rectangle :	draw_rectangle(x0, y0, x1, y1, true); break;
			case AREA_SHAPE.elipse :	draw_ellipse(x0, y0, x1, y1, true); break;
		}
	}
	
	var _hov = [ 0, 0, 0, 0 ], _hovPos = 0;
	
	if(interact) {
		     if(drag_type == 1) _r = value_snap(drag_sx - (_mx - drag_mx) / _s, _snx);
		else if(drag_type == 2) _t = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
		else if(drag_type == 3) _l = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
		else if(drag_type == 4) _b = value_snap(drag_sy - (_my - drag_my) / _s, _sny);
		
		if(drag_type) {
			var _sval = array_clone(showValue());
			if(unit.mode == VALUE_UNIT.reference) {
				var _ref = unit.reference();
				_sval[0] *= _ref[0];
				_sval[1] *= _ref[1];
				_sval[2] *= _ref[0];
				_sval[3] *= _ref[1];
			}
			
			     if(drag_type == 1) _sval[0] = _r;
			else if(drag_type == 2) _sval[1] = _t;
			else if(drag_type == 3) _sval[2] = _l;
			else if(drag_type == 4) _sval[3] = _b;
			
			if(setValueInspector(_sval))
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				drag_type = 0;
				UNDO_HOLDING = false;
			}
		}
		
		if(drawSize && point_in_circle(_mx, _my, xc, y0, 16)) {
			_hov[0] = 1;
			hover   = 1;
			
			if(mouse_press(mb_left, active)) {
				drag_type = 2;
				drag_sy   = _t;
				drag_my   = _my;
			}
		} else if(drawSize && point_in_circle(_mx, _my, xc, y1, 16)) {
			_hov[1] = 1;
			hover = 3;
			
			if(mouse_press(mb_left, active)) {
				drag_type = 4;
				drag_sy   = _b;
				drag_my   = _my;
			}
		} else if(drawSize && point_in_circle(_mx, _my, x0, yc, 16)) {
			_hov[2] = 1;
			hover = 0;
			
			if(mouse_press(mb_left, active)) {
				drag_type = 3;	
				drag_sx   = _l;
				drag_mx   = _mx;
			}
		} else if(drawSize && point_in_circle(_mx, _my, x1, yc, 16)) {
			_hov[3] = 1;
			hover = 2;
			
			if(mouse_press(mb_left, active)) {
				drag_type = 1;
				drag_sx   = _r;
				drag_mx   = _mx;
			}
		}
	}
	
	for( var i = 0; i < 4; i++ ) 
		__overlay_hover[i] = lerp_float(__overlay_hover[i], _hov[i], 4);
	
	if(drawSize) {
		if(drag_type == 0 || drag_type == 2) draw_anchor_line(__overlay_hover[0], xc, y0, 16,  0);
		if(drag_type == 0 || drag_type == 4) draw_anchor_line(__overlay_hover[1], xc, y1, 16,  0);
		if(drag_type == 0 || drag_type == 3) draw_anchor_line(__overlay_hover[2], x0, yc, 16, 90);
		if(drag_type == 0 || drag_type == 1) draw_anchor_line(__overlay_hover[3], x1, yc, 16, 90);
	}
	
	//draw_set_text(_f_p2b, fa_center, fa_center, COLORS._main_accent);
	//draw_text_add((x0 + x1) / 2, (y0 + y1) / 2, name);
	
	return hover;
}

function preview_overlay_area_two_point(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag) {
	var _val  = array_clone(getValue());
	var hover = -1;
	
	var __ax = array_safe_get_fast(_val, 0);
	var __ay = array_safe_get_fast(_val, 1);
	var __aw = array_safe_get_fast(_val, 2);
	var __ah = array_safe_get_fast(_val, 3);
	var __at = array_safe_get_fast(_val, 4);
	
	var _x0  = __ax - __aw;
	var _y0  = __ay - __ah;
	var _x1  = __ax + __aw;
	var _y1  = __ay + __ah;
	
	var x0 = _x0 * _s + _x;
	var y0 = _y0 * _s + _y;
	var x1 = _x1 * _s + _x;
	var y1 = _y1 * _s + _y;
	var xc = (x0 + x1) / 2;
	var yc = (y0 + y1) / 2;
	
	var drawPos  = _flag & 0b0001;
	var drawSize = _flag & 0b0010;
	
	if(drawSize) {
		draw_set_color(COLORS._main_accent);
		draw_set_circle_precision(32);
		switch(__at) {
			case AREA_SHAPE.rectangle :	draw_rectangle(x0, y0, x1, y1, true); break;
			case AREA_SHAPE.elipse :	draw_ellipse(x0, y0, x1, y1, true); break;
		}
	}
	
	var _hov = [ 0, 0, 0 ];
	var _r   = 10;
	
	if(interact) {
		if(drag_type) {
			var _sval = array_clone(showValue());
			if(unit.mode == VALUE_UNIT.reference) {
				var _ref = unit.reference();
				_sval[0] *= _ref[0];
				_sval[1] *= _ref[1];
				_sval[2] *= _ref[0];
				_sval[3] *= _ref[1];
			}
		}
		
		if(drag_type == 1) {
			var _xx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
			var _yy = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
			
			_sval[0]  = _xx;
			_sval[1]  = _yy;
			
			if(setValueInspector(_sval))
				UNDO_HOLDING = true;
								
			if(mouse_release(mb_left)) {
				drag_type = 0;
				UNDO_HOLDING = false;
			}
		} else if(drag_type == 2) {
			var _xx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
			var _yy = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
			
			_sval[2]  = _xx;
			_sval[3]  = _yy;
			
			if(setValueInspector(_sval))
				UNDO_HOLDING = true;
								
			if(mouse_release(mb_left)) {
				drag_type = 0;
				UNDO_HOLDING = false;
			}
		} else if(drag_type == 3) {
			var __x0 = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
			var __y0 = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
			var __x1 = value_snap(_x1 + (__x0 - _x0), _snx);
			var __y1 = value_snap(_y1 + (__y0 - _y0), _sny);
			
			_val[0] = __x0;
			_val[1] = __y0;
			_val[2] = __x1;
			_val[3] = __y1;
			
			if(setValueInspector(_val))
				UNDO_HOLDING = true;
								
			if(mouse_release(mb_left)) {
				drag_type = 0;
				UNDO_HOLDING = false;
			}
		}
		
		if(drawSize && point_in_circle(_mx, _my, x0, y0, 8)) {
			_hov[1] = 1;
			hover   = 1;
			
			if(mouse_press(mb_left, active)) {
				drag_type = 1;	
				drag_sx   = _x0;
				drag_sy   = _y0;
				drag_mx   = _mx;
				drag_my   = _my;
			}
		} else if(drawSize && point_in_circle(_mx, _my, x1, y1, 8)) {
			_hov[2] = 1;
			hover   = 2;
			
			if(mouse_press(mb_left, active)) {
				drag_type = 2;	
				drag_sx   = _x1;
				drag_sy   = _y1;
				drag_mx   = _mx;
				drag_my   = _my;
			}
		} else if(drawPos && point_in_rectangle(_mx, _my, x0, y0, x1, y1)) {
			_hov[0] = 1;
			hover   = 3;
			
			if(mouse_press(mb_left, active)) {
				drag_type = 3;	
				drag_sx   = _x0;
				drag_sy   = _y0;
				drag_mx   = _mx;
				drag_my   = _my;
			}
		}
	}
	
	for( var i = 0; i < 3; i++ ) 
		__overlay_hover[i] = lerp_float(__overlay_hover[i], _hov[i], 4);
		
	if(drawPos && (drag_type == 0 || drag_type == 3)) draw_anchor_cross(__overlay_hover[0], xc, yc, _r + 4);
	if(drawSize) {
		if(drag_type == 0 || drag_type == 1) draw_anchor(__overlay_hover[1], x0, y0, _r);
		if(drag_type == 0 || drag_type == 2) draw_anchor(__overlay_hover[2], x1, y1, _r);
	}
		
	//draw_set_text(_f_p2b, fa_center, fa_center, COLORS._main_accent);
	//draw_text_add((x0 + x1) / 2, (y0 + y1) / 2 - 4, name);
	
	return hover;
}

function preview_overlay_area_span(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag) {
	var _val  = array_clone(getValue());
	var hover = -1;
	var _ref  = unit.mode == VALUE_UNIT.reference? unit.reference() : [ 1, 1 ];

	var __ax = array_safe_get_fast(_val, 0);
	var __ay = array_safe_get_fast(_val, 1);
	var __aw = array_safe_get_fast(_val, 2);
	var __ah = array_safe_get_fast(_val, 3);
	var __at = array_safe_get_fast(_val, 4);
	
	var _ax = __ax * _s + _x;
	var _ay = __ay * _s + _y;
	var _aw = __aw * _s;
	var _ah = __ah * _s;
					
	var drawPos  = _flag & 0b0001;
	var drawSize = _flag & 0b0010;
		
	if(drawSize) {
		draw_set_color(COLORS._main_accent);
		draw_set_circle_precision(32);
		switch(__at) {
			case AREA_SHAPE.rectangle :	draw_rectangle(_ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah, true); break;
			case AREA_SHAPE.elipse :	draw_ellipse(_ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah, true); break;
		}
	}
	
	var _hov = [ 0, 0 ];
	var _r   = 10;
	
	if(point_in_circle(_mx, _my, _ax + _aw, _ay + _ah, _r))
		_hov[1] = 1;
	else if(point_in_rectangle(_mx, _my, _ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah))
		_hov[0] = 1;
	
	__overlay_hover[0] = lerp_float(__overlay_hover[0], _hov[0], 4);
	__overlay_hover[1] = lerp_float(__overlay_hover[1], _hov[1], 4);
	
	if((drag_type == 0 || drag_type == 1) && drawPos)  draw_anchor_cross(__overlay_hover[0], _ax, _ay, _r + 4);
	if((drag_type == 0 || drag_type == 2) && drawSize) draw_anchor(__overlay_hover[1], _ax + _aw, _ay + _ah, _r);
	
	if(!interact) return -1;
	
	if(drag_type == 1) {
		var _xx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
		var _yy = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
							
		if(key_mod_press(CTRL)) {
			_val[0] = round(_xx);
			_val[1] = round(_yy);
		} else {
			_val[0] = _xx;
			_val[1] = _yy;
		}
		
		_val[0] /= _ref[0];
		_val[1] /= _ref[1];
		_val[2] /= _ref[0];
		_val[3] /= _ref[1];
		
		if(setValueInspector(_val))
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	} else if(drag_type == 2) {
		var _dx = value_snap((_mx - drag_mx) / _s, _snx);
		var _dy = value_snap((_my - drag_my) / _s, _sny);
							
		if(key_mod_press(CTRL)) {
			_val[2] = round(_dx);
			_val[3] = round(_dy);
		} else {
			_val[2] = _dx;
			_val[3] = _dy;
		}
							
		if(keyboard_check(vk_shift)) {
			_val[2] = max(_dx, _dy);
			_val[3] = max(_dx, _dy);
		}
				
		_val[0] /= _ref[0];
		_val[1] /= _ref[1];
		_val[2] /= _ref[0];
		_val[3] /= _ref[1];
					
		if(setValueInspector(_val))
			UNDO_HOLDING = true;
			
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
						
	if(drawSize && point_in_circle(_mx, _my, _ax + _aw, _ay + _ah, 8)) {
		hover = 2;
		
		if(mouse_press(mb_left, active)) {
			drag_type = 2;
			drag_mx   = _ax;
			drag_my   = _ay;
		}
	} else if(drawPos && point_in_rectangle(_mx, _my, _ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah)) {
		hover = 1;
		
		if(mouse_press(mb_left, active)) {
			drag_type = 1;	
			drag_sx   = __ax;
			drag_sy   = __ay;
			drag_mx   = _mx;
			drag_my   = _my;
		}
	}
	
	return hover;
}

function preview_overlay_area(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag, display_data) {
	var _val  = array_clone(getValue());
	var hover = -1;
	if(is_array(_val[0])) return hover;
	
	var mode = editWidget.mode;
	
	__overlay_hover = array_verify(__overlay_hover, 5);
	
	switch(mode) {
		case AREA_MODE.area :	   return preview_overlay_area_span(      interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag);
		case AREA_MODE.padding :   return preview_overlay_area_padding(   interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag, display_data);
		case AREA_MODE.two_point : return preview_overlay_area_two_point( interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag);
	}
	
	return hover;
}