function preview_overlay_area_padding(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag, display_data) {
	var _val  = array_clone(getValue());
	var hovering = -1;
	
	if(!is_callable(display_data)) return hovering;
	
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
	
	var _rr = ui(16);
	
	if(drawSize) {
		draw_set_color(COLORS._main_accent);
		draw_set_circle_precision(32);
		switch(__at) {
			case AREA_SHAPE.rectangle :	draw_rectangle(x0, y0, x1, y1, true); break;
			case AREA_SHAPE.elipse :	draw_ellipse(x0, y0, x1, y1, true); break;
		}
	}
	
	var _hov = [ 0, 0, 0, 0 ], _hovPos = 0;
	
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
		
	if(hover) {
		if(drawSize && point_in_circle(_mx, _my, xc, y0, _rr)) {
			_hov[0] = 1;
			hovering = 1;
			
			if(mouse_press(mb_left, active)) {
				drag_type = 2;
				drag_sy   = _t;
				drag_my   = _my;
			}
		} else if(drawSize && point_in_circle(_mx, _my, xc, y1, _rr)) {
			_hov[1] = 1;
			hovering = 3;
			
			if(mouse_press(mb_left, active)) {
				drag_type = 4;
				drag_sy   = _b;
				drag_my   = _my;
			}
		} else if(drawSize && point_in_circle(_mx, _my, x0, yc, _rr)) {
			_hov[2] = 1;
			hovering = 0;
			
			if(mouse_press(mb_left, active)) {
				drag_type = 3;	
				drag_sx   = _l;
				drag_mx   = _mx;
			}
		} else if(drawSize && point_in_circle(_mx, _my, x1, yc, _rr)) {
			_hov[3] = 1;
			hovering = 2;
			
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
		if(drag_type == 0 || drag_type == 2) draw_anchor_line(__overlay_hover[0], xc, y0, _rr,  0);
		if(drag_type == 0 || drag_type == 4) draw_anchor_line(__overlay_hover[1], xc, y1, _rr,  0);
		if(drag_type == 0 || drag_type == 3) draw_anchor_line(__overlay_hover[2], x0, yc, _rr, 90);
		if(drag_type == 0 || drag_type == 1) draw_anchor_line(__overlay_hover[3], x1, yc, _rr, 90);
	}
	
	return hovering;
}

function preview_overlay_area_two_point(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag) {
	var _val  = array_clone(getValue());
	var hovering = -1;
	
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
	var _r   = ui(10);
	
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
	
	if(hover) {
		if(drawSize && point_in_circle(_mx, _my, x0, y0, ui(8))) {
			_hov[1] = 1;
			hovering = 1;
			
			if(mouse_press(mb_left, active)) {
				drag_type = 1;	
				drag_sx   = _x0;
				drag_sy   = _y0;
				drag_mx   = _mx;
				drag_my   = _my;
			}
		} else if(drawSize && point_in_circle(_mx, _my, x1, y1, ui(8))) {
			_hov[2] = 1;
			hovering = 2;
			
			if(mouse_press(mb_left, active)) {
				drag_type = 2;	
				drag_sx   = _x1;
				drag_sy   = _y1;
				drag_mx   = _mx;
				drag_my   = _my;
			}
		} else if(drawPos && point_in_rectangle(_mx, _my, x0, y0, x1, y1)) {
			_hov[0] = 1;
			hovering = 3;
			
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
		
	if(drawPos && (drag_type == 0 || drag_type == 3)) draw_anchor_cross(__overlay_hover[0], xc, yc, _r + ui(4));
	if(drawSize) {
		if(drag_type == 0 || drag_type == 1) draw_anchor(__overlay_hover[1], x0, y0, _r);
		if(drag_type == 0 || drag_type == 2) draw_anchor(__overlay_hover[2], x1, y1, _r);
	}
		
	//draw_set_text(f_p2b, fa_center, fa_center, COLORS._main_accent);
	//draw_text_add((x0 + x1) / 2, (y0 + y1) / 2 - 4, name);
	
	return hovering;
}

function preview_overlay_area_span(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag) {
	var _val = array_clone(getValue());
	var _ref = unit.mode == VALUE_UNIT.reference? unit.reference() : [ 1, 1 ];

	var __ax = array_safe_get_fast(_val, 0);
	var __ay = array_safe_get_fast(_val, 1);
	var __aw = array_safe_get_fast(_val, 2);
	var __ah = array_safe_get_fast(_val, 3);
	var __at = array_safe_get_fast(_val, 4);
	
	var _ax = __ax * _s + _x;
	var _ay = __ay * _s + _y;
	var _aw = __aw * _s;
	var _ah = __ah * _s;
	
	var __x0 = __ax - __aw, __x1 = __ax + __aw;
	var __y0 = __ay - __ah, __y1 = __ay + __ah;
	
	var x0 = _ax - _aw, x1 = _ax + _aw;
	var y0 = _ay - _ah, y1 = _ay + _ah;
	var xs = x1 + 16 * sign(_aw);
	var ys = y1 + 16 * sign(_ah);
			
	var _hov = -1;
	var _r   = ui(10);
			
	var drawPos  = _flag & 0b0001;
	var drawSize = _flag & 0b0010;
		
	if(drawSize) {
		draw_set_color(COLORS._main_accent);
		switch(__at) {
			case AREA_SHAPE.rectangle :	draw_rectangle(    x0, y0, x1, y1, true ); break;
			case AREA_SHAPE.elipse :	
				draw_rectangle_dashed( x0, y0, x1, y1 ); 
				draw_ellipse_prec(     x0, y0, x1, y1, true ); 
				break;
		}
		
		draw_line(x1, y1, xs, ys);
	}
	
	if(drawPos  && point_in_rectangle(_mx, _my, x0, y0, x1, y1)) _hov = 1;
	if(drawSize) {
		if(point_in_circle(_mx, _my, xs, ys, _r)) _hov = 2;
		if(point_in_circle(_mx, _my, x0, y0, _r)) _hov = 3;
		if(point_in_circle(_mx, _my, x1, y0, _r)) _hov = 4;
		if(point_in_circle(_mx, _my, x0, y1, _r)) _hov = 5;
		if(point_in_circle(_mx, _my, x1, y1, _r)) _hov = 6;
	}
	
	if(drawPos)  draw_anchor_cross(_hov == 1, _ax, _ay, ui(8), 1);
	if(drawSize) {
		draw_anchor(_hov == 2, xs, ys, ui(8), 1);
		draw_anchor(_hov == 3, x0, y0, ui(8), 2);
		draw_anchor(_hov == 4, x1, y0, ui(8), 2);
		draw_anchor(_hov == 5, x0, y1, ui(8), 2);
		draw_anchor(_hov == 6, x1, y1, ui(8), 2);
	}
	
	switch(drag_type) {
		case 1: // Move
			var _xx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
			var _yy = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
								
			if(key_mod_press(CTRL)) {
				_val[0] = round(_xx);
				_val[1] = round(_yy);
				
			} else {
				_val[0] = _xx;
				_val[1] = _yy;
			}
			break;
			
		case 2: // Scale
			var _xx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
			var _yy = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
								
			if(key_mod_press(CTRL)) {
				_val[2] = round(_xx);
				_val[3] = round(_yy);
				
			} else {
				_val[2] = _xx;
				_val[3] = _yy;
			}
								
			if(key_mod_press(SHIFT)) {
				_val[2] = max(_xx, _yy);
				_val[3] = max(_xx, _yy);
			}
			break;
			
		case 3 : // top-left
			var _xx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
			var _yy = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
			
			if(key_mod_press(CTRL)) {
				_xx = round(_xx);
				_yy = round(_yy);
			}
			
			_val[0] = (__x1 + _xx) / 2;
			_val[1] = (__y1 + _yy) / 2;
			_val[2] = abs(__x1 - _xx) / 2;
			_val[3] = abs(__y1 - _yy) / 2;
			break;
			
		case 4 : // top-right
			var _xx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
			var _yy = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
			
			if(key_mod_press(CTRL)) {
				_xx = round(_xx);
				_yy = round(_yy);
			}
			
			_val[0] = (__x0 + _xx) / 2;
			_val[1] = (__y1 + _yy) / 2;
			_val[2] = abs(__x0 - _xx) / 2;
			_val[3] = abs(__y1 - _yy) / 2;
			break;
			
		case 5 : // bottom-left
			var _xx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
			var _yy = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
			
			if(key_mod_press(CTRL)) {
				_xx = round(_xx);
				_yy = round(_yy);
			}
			
			_val[0] = (__x1 + _xx) / 2;
			_val[1] = (__y0 + _yy) / 2;
			_val[2] = abs(__x1 - _xx) / 2;
			_val[3] = abs(__y0 - _yy) / 2;
			break;
			
		case 6 : // bottom-right
			var _xx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
			var _yy = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
			
			if(key_mod_press(CTRL)) {
				_xx = round(_xx);
				_yy = round(_yy);
			}
			
			_val[0] = (__x0 + _xx) / 2;
			_val[1] = (__y0 + _yy) / 2;
			_val[2] = abs(__x0 - _xx) / 2;
			_val[3] = abs(__y0 - _yy) / 2;
			break;
	}
	
	if(drag_type) {
		_val[0] /= _ref[0];
		_val[1] /= _ref[1];
		_val[2] /= _ref[0];
		_val[3] /= _ref[1];
		
		if(setValueInspector(_val)) 
			UNDO_HOLDING = true;
			
		if(mouse_release(mb_left)) {
			drag_type    = 0;
			UNDO_HOLDING = false;
		}
	}
				
	if(hover && _hov && mouse_press(mb_left, active)) {
		drag_type = _hov;
		drag_mx   = _mx;
		drag_my   = _my;
		
		if(_hov == 1) {
			drag_sx = __ax;
			drag_sy = __ay;
			
		} else if(_hov == 2) {
			drag_sx = __aw;
			drag_sy = __ah;
			
		} else if(_hov == 3) {
			drag_sx = __x0;
			drag_sy = __y0;
			
		} else if(_hov == 4) {
			drag_sx = __x1;
			drag_sy = __y0;
			
		} else if(_hov == 5) {
			drag_sx = __x0;
			drag_sy = __y1;
			
		} else if(_hov == 6) {
			drag_sx = __x1;
			drag_sy = __y1;
			
		}
	}
	
	return _hov;
}

function preview_overlay_area(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag, display_data) {
	var _val  = array_clone(getValue());
	var hovering = -1;
	if(is_array(_val[0])) return hovering;
	
	var mode = editWidget.mode;
	
	__preview_bbox.addArea(_val);
	__overlay_hover = array_verify(__overlay_hover, 5);
	
	switch(mode) {
		case AREA_MODE.area :	   return preview_overlay_area_span(      hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag);
		case AREA_MODE.padding :   return preview_overlay_area_padding(   hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag, display_data);
		case AREA_MODE.two_point : return preview_overlay_area_two_point( hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag);
	}
	
	return hovering;
}