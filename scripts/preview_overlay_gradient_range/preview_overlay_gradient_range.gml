function preview_overlay_gradient_range(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _dim) {
	var _val   = array_clone(getValue());
	var _targI = node.inputs[mappedJunc.attributes.map_index];
	var _surf  = _targI.getValue();
	
	var hover  = -1;
	if(!is_array(_val) || array_empty(_val)) return hover;
	if(is_array(_val[0]))					 return hover;
	
	var _sw = _dim[0];
	var _sh = _dim[1];
	
	var __x0 = _val[0] * _sw;
	var __y0 = _val[1] * _sh;
	var __x1 = _val[2] * _sw;
	var __y1 = _val[3] * _sh;
						
	var _ax0 = __x0 * _s + _x;
	var _ay0 = __y0 * _s + _y;
	var _ax1 = __x1 * _s + _x;
	var _ay1 = __y1 * _s + _y;
	
	var cc = COLORS.labels[2];
	var _r = ui(10);
	
	__overlay_hover = array_verify(__overlay_hover, 2);
	if(surface_exists(_surf) && (__overlay_hover[0] > 0 || __overlay_hover[1] > 0))
		draw_surface_stretched_ext(_surf, _x, _y, _sw * _s, _sh * _s, c_white, 0.25);
	
	draw_set_text(f_p1, fa_left, fa_bottom, cc);
	draw_text_add(_ax0 + ui(4), _ay0 - ui(4), "1");
	draw_text_add(_ax1 + ui(4), _ay1 - ui(4), "2");
	
	var tx0, ty0, tx1, ty1;
	
	if(_ax0 > _ax1) {
		tx0 = _ax1; tx1 = _ax0;
		ty0 = _ay1; ty1 = _ay0;
	} else {
		tx0 = _ax0; tx1 = _ax1;
		ty0 = _ay0; ty1 = _ay1;
	}
	
	var dir = point_direction(tx0, ty0, tx1, ty1);
	var dis = point_distance( tx0, ty0, tx1, ty1);
	
	draw_set_text(f_p2b, fa_center, fa_center, cc);
	var txt = string_cut(mappedJunc.name, dis - ui(16));
	draw_text_transformed((tx0 + tx1) / 2, (ty0 + ty1) / 2, txt, 1, 1, dir);
	
	var _tw = string_width(txt) + ui(16);
	
	draw_set_color(cc);
	draw_line_round(tx0, ty0, tx0 + lengthdir_x(dis / 2 - _tw / 2, dir), ty0 + lengthdir_y(dis / 2 - _tw / 2, dir), 2);
	draw_line_round(tx1, ty1, tx1 - lengthdir_x(dis / 2 - _tw / 2, dir), ty1 - lengthdir_y(dis / 2 - _tw / 2, dir), 2);
	
	var d0 = false;
	var d1 = false;
	
	if(drag_type) {
		if(drag_type == 1) { d0 = true; }
		if(drag_type == 2) { d1 = true; }
		
		var _nx = value_snap((drag_sx + (_mx - drag_mx) - _x) / _s, _snx);
		var _ny = value_snap((drag_sy + (_my - drag_my) - _y) / _s, _sny);
		
		if(key_mod_press(CTRL)) {
			_nx = round(_nx);
			_ny = round(_ny);
		}
		
		_val[(drag_type - 1) * 2 + 0] = _nx / _sw;
		_val[(drag_type - 1) * 2 + 1] = _ny / _sh;
			
		if(setValueInspector( _val )) 
			UNDO_HOLDING = true;
		
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
		
	} else if(interact && active) {
		if(point_in_circle(_mx, _my, _ax0, _ay0, ui(8))) {
			d0 = true;
			hover = 1;
			
			if(mouse_press(mb_left, active)) {
				drag_type = hover;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sx   = _ax0;
				drag_sy   = _ay0;
			}
		} else if(point_in_circle(_mx, _my, _ax1, _ay1, ui(8))) {
			d1 = true;
			hover = 2;
			
			if(mouse_press(mb_left, active)) {
				drag_type = hover;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sx   = _ax1;
				drag_sy   = _ay1;
			}
		}
	} 
	
	__overlay_hover[0] = lerp_float(__overlay_hover[0], d0, 4);
	__overlay_hover[1] = lerp_float(__overlay_hover[1], d1, 4);
	
	draw_anchor(__overlay_hover[0], _ax0, _ay0, _r);
	draw_anchor(__overlay_hover[1], _ax1, _ay1, _r);
	
	return hover;
}