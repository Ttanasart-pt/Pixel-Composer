function preview_overlay_puppet(active, _x, _y, _s, _mx, _my, _snx, _sny) {
	var _val = getValue();
	var hover = -1;
	if(is_array(_val[0])) return hover;
	
	var __ax  = _val[PUPPET_CONTROL.cx];
	var __ay  = _val[PUPPET_CONTROL.cy];
	var __ax1 = _val[PUPPET_CONTROL.fx];
	var __ay1 = _val[PUPPET_CONTROL.fy];
						
	var _ax = __ax * _s + _x;
	var _ay = __ay * _s + _y;
						
	var _ax1 = (__ax + __ax1) * _s + _x;
	var _ay1 = (__ay + __ay1) * _s + _y;
						
	draw_set_color(COLORS._main_accent);
	switch(_val[PUPPET_CONTROL.mode]) {
		case PUPPET_FORCE_MODE.move :
			draw_line_width2(_ax, _ay, _ax1, _ay1, 6, 1);
						
			draw_sprite_ui_uniform(THEME.anchor_selector, 0, _ax, _ay);
			draw_sprite_ui_uniform(THEME.anchor_selector, 2, _ax1, _ay1);
			draw_circle(_ax, _ay, _val[PUPPET_CONTROL.width] * _s, true);
			break;
		case PUPPET_FORCE_MODE.pinch :
		case PUPPET_FORCE_MODE.inflate :
			draw_sprite_ui_uniform(THEME.anchor_selector, 0, _ax, _ay);
			draw_circle(_ax, _ay, _val[PUPPET_CONTROL.width] * _s, true);
			break;
		case PUPPET_FORCE_MODE.wind :
			var dir  = _val[PUPPET_CONTROL.fy];
			var rad  = _val[PUPPET_CONTROL.width] * _s;
								
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
			draw_sprite_ui_uniform(THEME.anchor_selector, 0, _ax, _ay);
			break;
	}
						
	if(drag_type == 1) {
		draw_sprite_ui_uniform(THEME.anchor_selector, 1, _ax, _ay);
		var _nx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
		var _ny = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
							
		if(key_mod_press(CTRL)) {
			_val[PUPPET_CONTROL.cx] = round(_nx);
			_val[PUPPET_CONTROL.cy] = round(_ny);
		} else {
			_val[PUPPET_CONTROL.cx] = _nx;
			_val[PUPPET_CONTROL.cy] = _ny;
		}
							
		if(setValue( _val ))
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	} else if(drag_type == 2) {
		draw_sprite_ui_uniform(THEME.anchor_selector, 0, _ax1, _ay1);
		var _nx = value_snap(drag_sx + (_mx - drag_mx) / _s, _snx);
		var _ny = value_snap(drag_sy + (_my - drag_my) / _s, _sny);
							
		if(key_mod_press(CTRL)) {
			_val[PUPPET_CONTROL.fx] = round(_nx);
			_val[PUPPET_CONTROL.fy] = round(_ny);
		} else {
			_val[PUPPET_CONTROL.fx] = _nx;
			_val[PUPPET_CONTROL.fy] = _ny;
		}
							
		if(setValue( _val ))
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
						
	if(point_in_circle(_mx, _my, _ax, _ay, 8)) {
		hover = 1;
		draw_sprite_ui_uniform(THEME.anchor_selector, 1, _ax, _ay);
		if(mouse_press(mb_left, active)) {
			drag_type = 1;
			drag_mx   = _mx;
			drag_my   = _my;
			drag_sx   = __ax;
			drag_sy   = __ay;
		}
	} 
						
	if(_val[PUPPET_CONTROL.mode] == PUPPET_FORCE_MODE.move && point_in_circle(_mx, _my, _ax1, _ay1, 8)) {
		hover = 2;
		draw_sprite_ui_uniform(THEME.anchor_selector, 0, _ax1, _ay1);
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