function preview_overlay_area_padding(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag, display_data) { #region
	var _val  = array_clone(getValue());
	var hover = -1;
	
	if(!is_callable(display_data)) return hover;
	
	var __ax = array_safe_get(_val, 0);
	var __ay = array_safe_get(_val, 1);
	var __aw = array_safe_get(_val, 2);
	var __ah = array_safe_get(_val, 3);
	var __at = array_safe_get(_val, 4);
	
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
	
	if(!interact) return -1;
	
	if(drawPos) draw_sprite_colored(THEME.anchor, 0, xc, yc);
	if(drawSize) {
		draw_sprite_colored(THEME.anchor_solid_hori, 0, xc, y0,, 0);
		draw_sprite_colored(THEME.anchor_solid_hori, 0, xc, y1,, 0);
		draw_sprite_colored(THEME.anchor_solid_hori, 0, x0, yc,, 90);
		draw_sprite_colored(THEME.anchor_solid_hori, 0, x1, yc,, 90);
	}
	
	     if(drag_type == 1) _r = value_snap(drag_sx - (_mx - drag_mx) / _s, _snx);
	else if(drag_type == 2) _t = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
	else if(drag_type == 3) _l = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
	else if(drag_type == 4) _b = value_snap(drag_sy - (_my - drag_my) / _s, _sny);
	
	if(drag_type) {
		var _val = [ _r, _t, _l, _b, __at ];
		if(setValue(_val)) UNDO_HOLDING = true;
		
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
	
	if(drawSize && active && point_in_circle(_mx, _my, xc, y0, 16)) {
		draw_sprite_colored(THEME.anchor_solid_hori, 1, xc, y0);
		hover = 1;
		
		if(mouse_press(mb_left)) {
			drag_type = 2;
			drag_sy   = _t;
			drag_my   = _my;
		}
	} else if(drawSize && active && point_in_circle(_mx, _my, xc, y1, 16)) {
		draw_sprite_colored(THEME.anchor_solid_hori, 1, xc, y1);
		hover = 3;
		
		if(mouse_press(mb_left)) {
			drag_type = 4;
			drag_sy   = _b;
			drag_my   = _my;
		}
	} else if(drawSize && active && point_in_circle(_mx, _my, x0, yc, 16)) {
		draw_sprite_colored(THEME.anchor_solid_hori, 1, x0, yc,, 90);
		hover = 0;
		
		if(mouse_press(mb_left)) {
			drag_type = 3;	
			drag_sx   = _l;
			drag_mx   = _mx;
		}
	} else if(drawSize && active && point_in_circle(_mx, _my, x1, yc, 16)) {
		draw_sprite_colored(THEME.anchor_solid_hori, 1, x1, yc,, 90);
		hover = 2;
		
		if(mouse_press(mb_left)) {
			drag_type = 1;
			drag_sx   = _r;
			drag_mx   = _mx;
		}
	}
	
	draw_set_text(_f_p2b, fa_center, fa_center, COLORS._main_accent);
	draw_text((x0 + x1) / 2, (y0 + y1) / 2, name);
	
	return hover;
} #endregion

function preview_overlay_area_two_point(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag) { #region
	var _val  = array_clone(getValue());
	var hover = -1;
	
	var __ax = array_safe_get(_val, 0);
	var __ay = array_safe_get(_val, 1);
	var __aw = array_safe_get(_val, 2);
	var __ah = array_safe_get(_val, 3);
	var __at = array_safe_get(_val, 4);
	
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
	
	if(!interact) return -1;
	
	if(drawPos) draw_sprite_colored(THEME.anchor, 1, xc, yc);
	if(drawSize) {
		draw_sprite_colored(THEME.anchor_selector, 0, x0, y0);
		draw_sprite_colored(THEME.anchor_selector, 0, x1, y1);
	}
	
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
	} else if(drag_type == 2) {
		var _xx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
		var _yy = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
		_val = [_x0, _y0, _xx, _yy, __at];
		
		if(setValue(_val))
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
		_val = [__x0, __y0, __x1, __y1, __at];
		
		if(setValue(_val))
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
	
	if(drawSize && active && point_in_circle(_mx, _my, x0, y0, 8)) {
		draw_sprite_colored(THEME.anchor_selector, 1, x0, y0);
		hover = 1;
		
		if(mouse_press(mb_left)) {
			drag_type = 1;	
			drag_sx   = _x0;
			drag_sy   = _y0;
			drag_mx   = _mx;
			drag_my   = _my;
		}
	} else if(drawSize && active && point_in_circle(_mx, _my, x1, y1, 8)) {
		draw_sprite_colored(THEME.anchor_selector, 1, x1, y1);
		hover = 2;
		
		if(mouse_press(mb_left)) {
			drag_type = 2;	
			drag_sx   = _x1;
			drag_sy   = _y1;
			drag_mx   = _mx;
			drag_my   = _my;
		}
	} else if(drawPos && active && point_in_rectangle(_mx, _my, x0, y0, x1, y1)) {
		draw_sprite_colored(THEME.anchor, 1, xc, yc);
		hover = 3;
		
		if(mouse_press(mb_left)) {
			drag_type = 3;	
			drag_sx   = _x0;
			drag_sy   = _y0;
			drag_mx   = _mx;
			drag_my   = _my;
		}
	}
	
	draw_set_text(_f_p2b, fa_center, fa_center, COLORS._main_accent);
	draw_text((x0 + x1) / 2, (y0 + y1) / 2, name);
	
	return hover;
} #endregion

function preview_overlay_area_span(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag) { #region
	var _val  = array_clone(getValue());
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
	
	if(!interact) return -1;
	
	if(drawPos)  draw_sprite_colored(THEME.anchor, 0, _ax, _ay);
	if(drawSize) draw_sprite_colored(THEME.anchor_selector, 0, _ax + _aw, _ay + _ah);
						
	if(point_in_circle(_mx, _my, _ax + _aw, _ay + _ah, 8))
		draw_sprite_colored(THEME.anchor_selector, 1, _ax + _aw, _ay + _ah);
	else if(point_in_rectangle(_mx, _my, _ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah))
		draw_sprite_colored(THEME.anchor, 0, _ax, _ay, 1.25);
						
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
						
	if(drawSize && active && point_in_circle(_mx, _my, _ax + _aw, _ay + _ah, 8)) {
		hover = 2;
		if(mouse_press(mb_left)) {
			drag_type = 2;
			drag_mx   = _ax;
			drag_my   = _ay;
		}
	} else if(drawPos && active && point_in_rectangle(_mx, _my, _ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah)) {
		hover = 1;
		if(mouse_press(mb_left)) {
			drag_type = 1;	
			drag_sx   = __ax;
			drag_sy   = __ay;
			drag_mx   = _mx;
			drag_my   = _my;
		}
	}
	
	draw_set_text(_f_p2b, fa_center, fa_bottom, COLORS._main_accent);
	draw_text(_ax, _ay - 4, name);
	
	return hover;
} #endregion

function preview_overlay_area(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag, display_data) {
	var _val  = array_clone(getValue());
	var hover = -1;
	if(is_array(_val[0])) return hover;
	
	var mode = editWidget.mode;
	
	switch(mode) {
		case AREA_MODE.area :	   return preview_overlay_area_span(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag);
		case AREA_MODE.padding :   return preview_overlay_area_padding(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag, display_data);
		case AREA_MODE.two_point : return preview_overlay_area_two_point(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _flag);
	}
	
	return hover;
}