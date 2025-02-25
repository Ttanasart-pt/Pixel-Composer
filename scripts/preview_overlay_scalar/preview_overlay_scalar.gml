function preview_overlay_scalar(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _angle, _scale, _type = 0) {
	var _val  = getValue();
	var hover = -1;
	if(!is_real(_val)) return hover;
	
	var index = 0;
	var __ax  = lengthdir_x(_val * _scale, _angle);
	var __ay  = lengthdir_y(_val * _scale, _angle);
	var _r    = ui(10);
	
	var _ax = _x + __ax * _s;
	var _ay = _y + __ay * _s;
						
	if(drag_type) {
		index = 1;
		var _dist = point_distance(_mx, _my, _x, _y) / (_s * _scale);
		var _sign = abs(angle_difference(point_direction(_mx, _my, _x, _y), _angle)) > 90? 1 : -1;
		
		if(key_mod_press(CTRL))
			_dist = round(_dist);
		_dist *= _sign;
		
		if(setValueInspector( unit.invApply(_dist) ))
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
	
	if(interact && point_in_circle(_mx, _my, _ax, _ay, _r)) {
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
	
	__overlay_hover = array_verify(__overlay_hover, 1);
	__overlay_hover[0] = lerp_float(__overlay_hover[0], index, 4);
	draw_anchor(__overlay_hover[0], _ax, _ay, _r, _type);
	
	if(overlay_draw_text) {
		if(overlay_text_valign == fa_top) {
			draw_set_text(f_p2b, fa_center, fa_bottom, COLORS._main_accent);
			draw_text_add(round(_ax), round(_ay - ui(4)), name);
			
		} else if(overlay_text_valign == fa_bottom) {
			draw_set_text(f_p2b, fa_center, fa_top, COLORS._main_accent);
			draw_text_add(round(_ax), round(_ay + ui(4)), name);
			
		}
	}
	
	return hover;
}