function preview_overlay_vector(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _type = 0, _scale = [ 1, 1 ], _angle = 0) {
	static __p = [0,0];
	
	var _val  = array_clone(getValue());
	var hover = -1;
	if(!is_array(_val) || array_empty(_val)) return hover;
	if(is_array(_val[0])) return hover;
	
	var __ax = _val[0];
	var __ay = _val[1];
	var _r   = ui(10);
						
	var _ax = __ax * _s * _scale[0] + _x;
	var _ay = __ay * _s * _scale[1] + _y;
	__p = point_rotate(_ax, _ay, _x, _y, _angle, __p);
	
	var _ax = __p[0];
	var _ay = __p[1];
	var _in = 0;
						
	if(drag_type) {
		_in = 1;
		
		_val[0] = drag_sx;
		_val[1] = drag_sy;
		
		var _nx = drag_sx + ((_mx - drag_mx) / _s / _scale[0]);
		var _ny = drag_sy + ((_my - drag_my) / _s / _scale[1]);
		__p = point_rotate(_nx, _ny, drag_sx, drag_sy, -_angle, __p);
		
		var _nx = __p[0];
		var _ny = __p[1];

		_nx = value_snap(_nx, _snx);
		_ny = value_snap(_ny, _sny);
		
		if(key_mod_press(SHIFT)) {
			if(abs(_mx - drag_mx) > abs(_my - drag_my)) 
				_ny = drag_ry;
			else
				_nx = drag_rx;
			
			var _sax = drag_sx * _s * _scale[0] + _x;
			var _say = drag_sy * _s * _scale[1] + _y;
	
			draw_set_color(COLORS._main_accent);
			draw_line(_sax, _say, _x + _nx * _s * _scale[0], _y + _ny * _s * _scale[1]);
		}
		
		if(key_mod_press(CTRL)) {
			_nx = round(_nx);
			_ny = round(_ny);
		} 
		
		if(preview_hotkey_axis == -1 || preview_hotkey_axis == 0) _val[0] = _nx;
		if(preview_hotkey_axis == -1 || preview_hotkey_axis == 1) _val[1] = _ny;
							
		if(setValueInspector( unit.invApply(_val) )) 
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
						
	if(interact && point_in_circle(_mx, _my, _ax, _ay, _r)) {
		hover  = 1;
		_in = 1;
		
		if(mouse_press(mb_left, active)) {
			drag_type = 1;
			drag_mx   = _mx;
			drag_my   = _my;
			drag_sx   = _val[0];
			drag_sy   = _val[1];
			drag_rx   = __ax;
			drag_ry   = __ay;
			
			KEYBOARD_STRING     = "";
			preview_hotkey_axis = -1;
		}
	} 
	
	__overlay_hover = array_verify(__overlay_hover, 1);
	__overlay_hover[0] = lerp_float(__overlay_hover[0], _in, 4);
	if(_type == 1) draw_sprite_ui(THEME.arrow4_24, 0, _ax, _ay, 1, 1, 0, COLORS._main_accent);
	
	draw_anchor(__overlay_hover[0], _ax, _ay, _r, _type);
	
	if(overlay_draw_text) {
		var _tx = round(_ax);
		var _ty = round(_ay - ui(4));
		
		draw_set_text(f_p4, fa_center, fa_bottom, COLORS._main_accent);
		draw_text_add(_tx, _ty, overlay_label == ""? name : overlay_label);
	}
	
	return hover;
}