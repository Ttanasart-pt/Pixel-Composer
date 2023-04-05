function preview_overlay_scalar(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _angle, _scale, _spr) {
	var _val = getValue();
	var hover = -1;
	if(is_array(_val)) return hover;
	
	var index = 0;
	var __ax = lengthdir_x(_val * _scale, _angle);
	var __ay = lengthdir_y(_val * _scale, _angle);
						
	var _ax = _x + __ax * _s;
	var _ay = _y + __ay * _s;
						
	if(drag_type) {
		index = 1;
		var dist = point_distance(_mx, _my, _x, _y) / _s / _scale;
		if(key_mod_press(CTRL))
			dist = round(dist);
							
		if(setValue( dist ))
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
						
	if(interact && point_in_circle(_mx, _my, _ax, _ay, 8)) {
		hover = 1;
		index = 1;
		if(mouse_press(mb_left, active)) {
			drag_type = 1;
			drag_mx   = _mx;
			drag_my   = _my;
			drag_sx   = _ax;
			drag_sy   = _ay;
		}
	} 
						
	draw_sprite_ui_uniform(_spr, index, _ax, _ay);
	
	return hover;
}