function preview_overlay_area_padding(active, _x, _y, _s, _mx, _my, _snx, _sny, display_data) {
	var _val = showValue();
	var hover = -1;
	
	if(display_data == -1) return hover;
	
	var ss = display_data();
	var __at = array_safe_get(_val, 4);
	var _r = array_safe_get(_val, 0);
	var _t = array_safe_get(_val, 1);
	var _l = array_safe_get(_val, 2);
	var _b = array_safe_get(_val, 3);
	var _xc = ((ss[0] - _r) + _l) / 2;
	var _yc = ((ss[1] - _b) + _t) / 2;
	
	var x0 = _l * _s + _x;
	var y0 = _t * _s + _y;
	var x1 = (ss[0] - _r) * _s + _x;
	var y1 = (ss[1] - _b) * _s + _y;
	var xc = (x0 + x1) / 2;
	var yc = (y0 + y1) / 2;
	
	draw_set_color(COLORS._main_accent);
	switch(__at) {
		case AREA_SHAPE.rectangle :	draw_rectangle(x0, y0, x1, y1, true); break;
		case AREA_SHAPE.elipse :	draw_ellipse(x0, y0, x1, y1, true); break;
	}
	
	draw_sprite_ui_uniform(THEME.anchor, 0, xc, yc);
	draw_sprite_ui_uniform(THEME.anchor_solid_hori, 0, xc, y0,,,, 0);
	draw_sprite_ui_uniform(THEME.anchor_solid_hori, 0, xc, y1,,,, 0);
	draw_sprite_ui_uniform(THEME.anchor_solid_hori, 0, x0, yc,,,, 90);
	draw_sprite_ui_uniform(THEME.anchor_solid_hori, 0, x1, yc,,,, 90);
	
	if(drag_type == 1) {
		var _xx = value_snap(drag_sx - (_mx - drag_mx) / _s, _snx);
		_val[0] = _xx;
		
		if(setValue(_val))
			UNDO_HOLDING = true;
	} else if(drag_type == 2) {
		var _yy = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
		_val[1] = _yy;
		
		if(setValue(_val))
			UNDO_HOLDING = true;
	} else if(drag_type == 3) {
		var _xx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
		_val[2] = _xx;
		
		if(setValue(_val))
			UNDO_HOLDING = true;
	} else if(drag_type == 4) {
		var _yy = value_snap(drag_sy - (_my - drag_my) / _s, _sny);
		_val[3] = _yy;
		
		if(setValue(_val))
			UNDO_HOLDING = true;
	} else if(drag_type == 5) {
		var _xx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
		var _yy = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
		var _w  = ss[0] - _r - _l;
		var _h  = ss[1] - _b - _t;
		
		var nr  = ss[0] - (_xx + _w / 2);
		var nl  = _xx - _w / 2;
		var nt  = _yy - _h / 2;
		var nb  = ss[1] - (_yy + _h / 2);
		
		_val = [ nr, nt, nl, nb, __at ];
		
		if(setValue(_val))
			UNDO_HOLDING = true;
	}
	
	if(drag_type && mouse_release(mb_left)) {
		drag_type = 0;
		UNDO_HOLDING = false;
	}
	
	if(active && point_in_circle(_mx, _my, xc, y0, 16)) {
		draw_sprite_ui_uniform(THEME.anchor_solid_hori, 1, xc, y0,,,, 0);
		hover = 1;
		
		if(mouse_press(mb_left)) {
			drag_type = 2;
			drag_sy   = _t;
			drag_my   = _my;
		}
	} else if(active && point_in_circle(_mx, _my, xc, y1, 16)) {
		draw_sprite_ui_uniform(THEME.anchor_solid_hori, 1, xc, y1,,,, 0);
		hover = 3;
		
		if(mouse_press(mb_left)) {
			drag_type = 4;
			drag_sy   = _b;
			drag_my   = _my;
		}
	} else if(active && point_in_circle(_mx, _my, x0, yc, 16)) {
		draw_sprite_ui_uniform(THEME.anchor_solid_hori, 1, x0, yc,,,, 90);
		hover = 0;
		
		if(mouse_press(mb_left)) {
			drag_type = 3;	
			drag_sx   = _l;
			drag_mx   = _mx;
		}
	} else if(active && point_in_circle(_mx, _my, x1, yc, 16)) {
		draw_sprite_ui_uniform(THEME.anchor_solid_hori, 1, x1, yc,,,, 90);
		hover = 2;
		
		if(mouse_press(mb_left)) {
			drag_type = 1;
			drag_sx   = _r;
			drag_mx   = _mx;
		}
	} else if(active && point_in_rectangle(_mx, _my, x0, y0, x1, y1)) {
		draw_sprite_ui_uniform(THEME.anchor, 1, xc, yc);
		hover = 4;
		
		if(mouse_press(mb_left)) {
			drag_type = 5;
			drag_sx   = _xc;
			drag_sy   = _yc;
			drag_mx   = _mx;
			drag_my   = _my;
		}
	}
	
	return hover;
}

function preview_overlay_area_two_point(active, _x, _y, _s, _mx, _my, _snx, _sny) {
	var _val = showValue();
	var hover = -1;
	
	var __at = array_safe_get(_val, 4);
	
	var _x0 = array_safe_get(_val, 0);
	var _y0 = array_safe_get(_val, 1);
	var _x1 = array_safe_get(_val, 2);
	var _y1 = array_safe_get(_val, 3);
	
	var x0 = _x0 * _s + _x;
	var y0 = _y0 * _s + _y;
	var x1 = _x1 * _s + _x;
	var y1 = _y1 * _s + _y;
	
	draw_set_color(COLORS._main_accent);
	switch(__at) {
		case AREA_SHAPE.rectangle :	draw_rectangle(x0, y0, x1, y1, true); break;
		case AREA_SHAPE.elipse :	draw_ellipse(x0, y0, x1, y1, true); break;
	}
	
	draw_sprite_ui_uniform(THEME.anchor_selector, 0, x0, y0);
	draw_sprite_ui_uniform(THEME.anchor_selector, 0, x1, y1);
	
	if(drag_type == 1) {
		var _xx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
		var _yy = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
		_val = [_xx, _yy, _x1, _y1, __at];
		
		if(setValue(_val))
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
	
	if(drag_type == 2) {
		var _xx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
		var _yy = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
		_val = [_x0, _y0, _xx, _yy, __at];
		
		if(setValue(_val))
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
	
	if(active && point_in_circle(_mx, _my, x0, y0, 8)) {
		draw_sprite_ui_uniform(THEME.anchor_selector, 1, x0, y0);
		hover = 1;
		
		if(mouse_press(mb_left)) {
			drag_type = 1;	
			drag_sx   = _x0;
			drag_sy   = _y0;
			drag_mx   = _mx;
			drag_my   = _my;
		}
	} else if(active && point_in_circle(_mx, _my, x1, y1, 8)) {
		draw_sprite_ui_uniform(THEME.anchor_selector, 1, x1, y1);
		hover = 2;
		
		if(mouse_press(mb_left)) {
			drag_type = 2;	
			drag_sx   = _x1;
			drag_sy   = _y1;
			drag_mx   = _mx;
			drag_my   = _my;
		}
	}
	
	return hover;
}

function preview_overlay_area_span(active, _x, _y, _s, _mx, _my, _snx, _sny) {
	var _val = showValue();
	var hover = -1;
	
	var __ax = array_safe_get(_val, 0);
	var __ay = array_safe_get(_val, 1);
	var __aw = array_safe_get(_val, 2);
	var __ah = array_safe_get(_val, 3);
	var __at = array_safe_get(_val, 4);
						
	var _ax = __ax * _s + _x;
	var _ay = __ay * _s + _y;
	var _aw = __aw * _s;
	var _ah = __ah * _s;
						
	draw_set_color(COLORS._main_accent);
	switch(__at) {
		case AREA_SHAPE.rectangle :	draw_rectangle(_ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah, true); break;
		case AREA_SHAPE.elipse :	draw_ellipse(_ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah, true); break;
	}
	
	draw_sprite_ui_uniform(THEME.anchor, 0, _ax, _ay);
	draw_sprite_ui_uniform(THEME.anchor_selector, 0, _ax + _aw, _ay + _ah);
						
	if(point_in_circle(_mx, _my, _ax + _aw, _ay + _ah, 8))
		draw_sprite_ui_uniform(THEME.anchor_selector, 1, _ax + _aw, _ay + _ah);
	else if(point_in_rectangle(_mx, _my, _ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah))
		draw_sprite_ui_uniform(THEME.anchor, 0, _ax, _ay, 1.25, c_white);
						
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
							
		if(setValue(_val))
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
							
		if(setValue(_val))
			UNDO_HOLDING = true;
			
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
						
	if(active && point_in_circle(_mx, _my, _ax + _aw, _ay + _ah, 8)) {
		hover = 2;
		if(mouse_press(mb_left)) {
			drag_type = 2;
			drag_mx   = _ax;
			drag_my   = _ay;
		}
	} else if(active && point_in_rectangle(_mx, _my, _ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah)) {
		hover = 1;
		if(mouse_press(mb_left)) {
			drag_type = 1;	
			drag_sx   = __ax;
			drag_sy   = __ay;
			drag_mx   = _mx;
			drag_my   = _my;
		}
	}
	
	return hover;
}

function preview_overlay_area(active, _x, _y, _s, _mx, _my, _snx, _sny, display_data) {
	var _val = getValue();
	var hover = -1;
	if(is_array(_val[0])) return hover;
	
	var mode = editWidget.mode;
	
	if(mode == AREA_MODE.area)
		hover =  preview_overlay_area_span(active, _x, _y, _s, _mx, _my, _snx, _sny);
	else if(mode == AREA_MODE.padding) 
		hover = preview_overlay_area_padding(active, _x, _y, _s, _mx, _my, _snx, _sny, display_data)
	else if(mode == AREA_MODE.two_point) 
		hover = preview_overlay_area_two_point(active, _x, _y, _s, _mx, _my, _snx, _sny);
	
	return hover;
}