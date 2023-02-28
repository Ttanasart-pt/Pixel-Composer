function preview_overlay_vector(active, _x, _y, _s, _mx, _my, _snx, _sny, _spr) {
	var _val = getValue();
	var hover = -1;
	if(is_array(_val[0])) return hover;
	
	var __ax = _val[0];
	var __ay = _val[1];
						
	var _ax = __ax * _s + _x;
	var _ay = __ay * _s + _y;
						
	draw_sprite_ui_uniform(_spr, 0, _ax, _ay);
						
	if(drag_type) {
		draw_sprite_ui_uniform(_spr, 1, _ax, _ay);
		var _nx = value_snap((drag_sx + (_mx - drag_mx) - _x) / _s, _snx);
		var _ny = value_snap((drag_sy + (_my - drag_my) - _y) / _s, _sny);
		if(key_mod_press(CTRL)) {
			_val[0] = round(_nx);
			_val[1] = round(_ny);
		} else {
			_val[0] = _nx;
			_val[1] = _ny;
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
		draw_sprite_ui_uniform(_spr, 1, _ax, _ay);
		if(mouse_press(mb_left, active)) {
			drag_type = 1;
			drag_mx   = _mx;
			drag_my   = _my;
			drag_sx   = _ax;
			drag_sy   = _ay;
		}
	} 
	
	return hover;
}