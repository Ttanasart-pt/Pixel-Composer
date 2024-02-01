function preview_overlay_vector(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _spr) {
	var _val  = array_clone(getValue());
	var hover = -1;
	if(!is_array(_val) || array_empty(_val)) return hover;
	if(is_array(_val[0])) return hover;
	
	var __ax = _val[0];
	var __ay = _val[1];
						
	var _ax = __ax * _s + _x;
	var _ay = __ay * _s + _y;
	var _id = 0;
						
	if(drag_type) {
		_id = 1;
		
		var _nx = value_snap((drag_sx + (_mx - drag_mx) - _x) / _s, _snx);
		var _ny = value_snap((drag_sy + (_my - drag_my) - _y) / _s, _sny);
		if(key_mod_press(CTRL)) {
			_val[0] = round(_nx);
			_val[1] = round(_ny);
		} else {
			_val[0] = _nx;
			_val[1] = _ny;
		}
							
		if(setValueInspector( _val )) 
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
						
	if(interact && active && point_in_circle(_mx, _my, _ax, _ay, 8)) {
		_id = 1;
		
		if(mouse_press(mb_left, active)) {
			drag_type = 1;
			drag_mx   = _mx;
			drag_my   = _my;
			drag_sx   = _ax;
			drag_sy   = _ay;
		}
	} 
	
	draw_sprite_colored(_spr, _id, _ax, _ay);
	draw_set_text(_f_p2b, fa_center, fa_bottom, COLORS._main_accent);
	draw_text(_ax, _ay - 4, name);
	
	return hover;
}