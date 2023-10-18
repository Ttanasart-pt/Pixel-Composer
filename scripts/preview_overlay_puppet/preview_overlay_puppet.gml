function preview_overlay_puppet(interact, active, _x, _y, _s, _mx, _my, _snx, _sny) {
	var _val  = array_clone(getValue());
	var hover = -1;
	if(is_array(_val[0])) return hover;
	
	var __ax  = _val[PUPPET_CONTROL.cx];
	var __ay  = _val[PUPPET_CONTROL.cy];
	var __ax1 = _val[PUPPET_CONTROL.fx];
	var __ay1 = _val[PUPPET_CONTROL.fy];
	var __wd  = _val[PUPPET_CONTROL.width];
						
	var _ax = __ax * _s + _x;
	var _ay = __ay * _s + _y;
						
	var _ax1 = (__ax + __ax1) * _s + _x;
	var _ay1 = (__ay + __ay1) * _s + _y;
						
	draw_set_color(COLORS._main_accent);
	switch(_val[PUPPET_CONTROL.mode]) {
		case PUPPET_FORCE_MODE.move :
			draw_line_width2(_ax, _ay, _ax1, _ay1, 6, 1);
			draw_circle_prec(_ax, _ay, __wd * _s, true);
			
			draw_sprite_colored(THEME.anchor_selector, 0, _ax, _ay);
			draw_sprite_colored(THEME.anchor_selector, 2, _ax1, _ay1);
			
			if(point_in_circle(_mx, _my, _ax + __wd * _s, _ay, 8)) {
				hover = 3;
				draw_sprite_colored(THEME.anchor_scale_hori, 1, _ax + __wd * _s, _ay);
				if(mouse_press(mb_left, active)) {
					drag_type = 3;
					drag_mx   = _mx;
					drag_sx   = __wd;
				}
			} else 
				draw_sprite_colored(THEME.anchor_scale_hori, drag_type == 3, _ax + __wd * _s, _ay);
			break;
		case PUPPET_FORCE_MODE.wind :
			var dir  = _val[PUPPET_CONTROL.fy];
			var str  = _val[PUPPET_CONTROL.fx] * _s;
			var rad  = _val[PUPPET_CONTROL.width] * _s;
								
			var _lx  = _ax + lengthdir_x(str, dir);
			var _ly  = _ay + lengthdir_y(str, dir);
								
			var _l0x = _ax + lengthdir_x(rad, dir + 90);
			var _l0y = _ay + lengthdir_y(rad, dir + 90);
			var _l1x = _ax + lengthdir_x(rad, dir - 90);
			var _l1y = _ay + lengthdir_y(rad, dir - 90);
								
			var _l0x0 = _l0x + lengthdir_x(1000, dir);
			var _l0y0 = _l0y + lengthdir_y(1000, dir);
			var _l0x1 = _l0x + lengthdir_x(1000, dir + 180);
			var _l0y1 = _l0y + lengthdir_y(1000, dir + 180);
								
			var _l1x0 = _l1x + lengthdir_x(1000, dir);
			var _l1y0 = _l1y + lengthdir_y(1000, dir);
			var _l1x1 = _l1x + lengthdir_x(1000, dir + 180);
			var _l1y1 = _l1y + lengthdir_y(1000, dir + 180);
			
			draw_line(_l0x0, _l0y0, _l0x1, _l0y1);
			draw_line(_l1x0, _l1y0, _l1x1, _l1y1);
			draw_sprite_colored(THEME.anchor_selector, 0, _ax, _ay);
			
			if(point_in_circle(_mx, _my, _l0x, _l0y, 8)) {
				hover = 4;
				draw_sprite_colored(THEME.anchor_scale_hori, 1, _l0x, _l0y,, dir + 90);
				if(mouse_press(mb_left, active)) {
					drag_type = 4;
					drag_sx   = _ax;
					drag_sy   = _ay;
				}
			} else 
				draw_sprite_colored(THEME.anchor_scale_hori, drag_type == 4, _l0x, _l0y,, dir + 90);
			
			if(point_in_circle(_mx, _my, _lx, _ly, 8)) {
				hover = 5;
				draw_sprite_colored(THEME.anchor_scale_hori, 1, _lx, _ly,, dir);
				if(mouse_press(mb_left, active)) {
					drag_type = 5;
					drag_sx   = _ax;
					drag_sy   = _ay;
				}
			} else 
				draw_sprite_colored(THEME.anchor_scale_hori, drag_type == 5, _lx, _ly,, dir);
			
			var rx = _ax + lengthdir_x(64, dir + 45);
			var ry = _ay + lengthdir_y(64, dir + 45);
			
			if(point_in_circle(_mx, _my, rx, ry, 8)) {
				draw_set_color(COLORS._main_accent);
				draw_circle_prec(_ax, _ay, 64, true);
				
				hover = 6;
				draw_sprite_colored(THEME.anchor_rotate, 1, rx, ry,, dir - 45);
				if(mouse_press(mb_left, active)) {
					drag_type = 6;
					drag_sx   = _ax;
					drag_sy   = _ay;
				}
			} else 
				draw_sprite_colored(THEME.anchor_rotate, drag_type == 6, rx, ry,, dir - 45);
			break;
	}
						
	if(drag_type == 1) {
		draw_sprite_colored(THEME.anchor_selector, 1, _ax, _ay);
		var _nx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
		var _ny = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
							
		if(key_mod_press(CTRL)) {
			_val[PUPPET_CONTROL.cx] = round(_nx);
			_val[PUPPET_CONTROL.cy] = round(_ny);
		} else {
			_val[PUPPET_CONTROL.cx] = _nx;
			_val[PUPPET_CONTROL.cy] = _ny;
		}
	} else if(drag_type == 2) {
		draw_sprite_colored(THEME.anchor_selector, 0, _ax1, _ay1);
		var _nx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
		var _ny = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
							
		if(key_mod_press(CTRL)) {
			_val[PUPPET_CONTROL.fx] = round(_nx);
			_val[PUPPET_CONTROL.fy] = round(_ny);
		} else {
			_val[PUPPET_CONTROL.fx] = _nx;
			_val[PUPPET_CONTROL.fy] = _ny;
		}
	} else if(drag_type == 3) {
		var _nx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
			
		if(key_mod_press(CTRL))
			_val[PUPPET_CONTROL.width] = round(_nx);
		else
			_val[PUPPET_CONTROL.width] = _nx;
	} else if(drag_type == 4) {
		var _nx = value_snap(point_distance(_mx, _my, drag_sx, drag_sy) / _s, _snx);
			
		if(key_mod_press(CTRL))
			_val[PUPPET_CONTROL.width] = round(_nx);
		else
			_val[PUPPET_CONTROL.width] = _nx;
	} else if(drag_type == 5) {
		var _nx = value_snap(point_distance(_mx, _my, drag_sx, drag_sy) / _s, _snx);
			
		if(key_mod_press(CTRL))
			_val[PUPPET_CONTROL.fx] = round(_nx);
		else
			_val[PUPPET_CONTROL.fx] = _nx;
	} else if(drag_type == 6) {
		var _nx = point_direction(drag_sx, drag_sy, _mx, _my) - 45;
			
		if(key_mod_press(CTRL))
			_val[PUPPET_CONTROL.fy] = round(_nx);
		else
			_val[PUPPET_CONTROL.fy] = _nx;
	}
	
	if(drag_type > 0) {
		if(setValue( _val ))
			UNDO_HOLDING = true;
			
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
						
	if(interact && active && point_in_circle(_mx, _my, _ax, _ay, 8)) {
		hover = 1;
		draw_sprite_colored(THEME.anchor_selector, 1, _ax, _ay);
		if(mouse_press(mb_left, active)) {
			drag_type = 1;
			drag_mx   = _mx;
			drag_my   = _my;
			drag_sx   = __ax;
			drag_sy   = __ay;
		}
	} 
						
	if(interact && active && _val[PUPPET_CONTROL.mode] == PUPPET_FORCE_MODE.move && point_in_circle(_mx, _my, _ax1, _ay1, 8)) {
		hover = 2;
		draw_sprite_colored(THEME.anchor_selector, 0, _ax1, _ay1);
		if(mouse_press(mb_left, active)) {
			drag_type = 2;
			drag_mx   = _mx;
			drag_my   = _my;
			drag_sx   = __ax1;
			drag_sy   = __ay1;
		}
	} 
	
	return hover;
}