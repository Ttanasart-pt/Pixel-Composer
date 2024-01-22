function preview_overlay_gradient_range(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _dim) {
	var _val  = array_clone(getValue());
	var hover = -1;
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
	
	draw_set_color(COLORS._main_accent);
	draw_line(_ax0, _ay0, _ax1, _ay1);
	
	var d0 = false;
	var d1 = false;
	
	draw_set_text(f_p1, fa_left, fa_bottom, COLORS._main_accent);
	draw_text(_ax0 + ui(4), _ay0 - ui(4), "1");
	draw_text(_ax1 + ui(4), _ay1 - ui(4), "2");
		
	if(drag_type) {
		if(drag_type == 1) { draw_sprite_colored(THEME.anchor_selector, 1, _ax0, _ay0); d0 = true; }
		if(drag_type == 2) { draw_sprite_colored(THEME.anchor_selector, 1, _ax1, _ay1); d1 = true; }
		
		var _nx = value_snap((drag_sx + (_mx - drag_mx) - _x) / _s, _snx);
		var _ny = value_snap((drag_sy + (_my - drag_my) - _y) / _s, _sny);
		
		if(key_mod_press(CTRL)) {
			_nx = round(_nx);
			_ny = round(_ny);
		}
		
		_val[(drag_type - 1) * 2 + 0] = _nx / _sw;
		_val[(drag_type - 1) * 2 + 1] = _ny / _sh;
			
		if(setValue( _val )) 
			UNDO_HOLDING = true;
		
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
		
	} else if(interact && active) {
		if(point_in_circle(_mx, _my, _ax0, _ay0, 8)) {
			d0 = true;
			hover = 1;
			
			draw_sprite_colored(THEME.anchor_selector, 1, _ax0, _ay0);
			
			if(mouse_press(mb_left, active)) {
				drag_type = hover;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sx   = _ax0;
				drag_sy   = _ay0;
			}
		} else if(point_in_circle(_mx, _my, _ax1, _ay1, 8)) {
			d1 = true;
			hover = 2;
			
			draw_sprite_colored(THEME.anchor_selector, 1, _ax1, _ay1);
			
			if(mouse_press(mb_left, active)) {
				drag_type = hover;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sx   = _ax1;
				drag_sy   = _ay1;
			}
		}
	} 

	if(d0 == false) draw_sprite_colored(THEME.anchor_selector, 0, _ax0, _ay0);
	if(d1 == false) draw_sprite_colored(THEME.anchor_selector, 0, _ax1, _ay1);
		
	return hover;
}