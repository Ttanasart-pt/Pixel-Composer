function preview_overlay_scalar(interact, active, _x, _y, _s, _mx, _my, _angle, _scale, _type = 0) {
	var _val   = getValue();
	var _hover = -1;
	if(!is_real(_val)) return _hover;
	
	////- Hotkey
	
	if(preview_hotkey_active) {
		_hover = 1;
		var _mmx = preview_hotkey_mx;
		var _mmy = preview_hotkey_my;
		
		var _aa = point_direction(_mmx, _mmy, _mx, _my);
		var _as = angle_difference(_aa, _angle);
		var _ds = point_distance(_mmx, _mmy, _mx, _my);
		var _pj = dcos(_as) * _ds;
		
		var _vx = preview_hotkey_s + _pj / _s / _scale;
		
		if(KEYBOARD_NUMBER != undefined) _vx = preview_hotkey_s + KEYBOARD_NUMBER;
		if(setValue(_vx)) UNDO_HOLDING = true;
		
		draw_set_color(COLORS._main_icon);
		draw_line_dashed(_x - lengthdir_x(9999, _angle), _y - lengthdir_y(9999, _angle), 
		                 _x + lengthdir_x(9999, _angle), _y + lengthdir_y(9999, _angle));
		
		if(mouse_lpress() || key_press(vk_enter) || preview_hotkey.isPressing()) {
			preview_hotkey_active = false;
			UNDO_HOLDING = false;
		}
		
	}
	
	if(active && preview_hotkey && preview_hotkey.isPressing()) {
		preview_hotkey_active = true;
		
		preview_hotkey_s  = _val;
		preview_hotkey_mx = _mx;
		preview_hotkey_my = _my;
		
		KEYBOARD_STRING = "";
	}
	
	////- Draw
	
	var index = 0;
	var __ax  = lengthdir_x(_val * _scale, _angle);
	var __ay  = lengthdir_y(_val * _scale, _angle);
	var _r    = ui(10);
	
	__preview_bbox.addPoint(__ax, __ay);
	
	var _ax = _x + __ax * _s;
	var _ay = _y + __ay * _s;
						
	if(drag_type) {
		index = 1;
		
		var _dist = point_project_distance_line_angle(_mx, _my, _x, _y, _angle) / (_s * _scale);
		if(key_mod_press(CTRL)) _dist = round(_dist);
		
		if(setValueInspector( unit.invApply(_dist) ))
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
	
	if(interact && point_in_circle(_mx, _my, _ax, _ay, _r)) {
		_hover = 1;
		 index = 1;
		
		if(mouse_press(mb_left, active)) {
			drag_type = 1;
			drag_mx   = _mx;
			drag_my   = _my;
			drag_sx   = _ax;
			drag_sy   = _ay;
		}
	} 
	
	draw_set_color(COLORS._main_accent);
	draw_line_dashed(_x, _y, _ax, _ay);
	
	__overlay_hover = array_verify(__overlay_hover, 1);
	__overlay_hover[0] = lerp_float(__overlay_hover[0], index, 4);
	draw_anchor(__overlay_hover[0], _ax, _ay, _r, _type);
	
	if(overlay_draw_text) {
		if(overlay_text_valign == fa_top) {
			draw_set_text(f_p4, fa_center, fa_bottom, COLORS._main_accent);
			draw_text_add(round(_ax), round(_ay - ui(4)), overlay_label == ""? name : overlay_label);
			
		} else if(overlay_text_valign == fa_bottom) {
			draw_set_text(f_p4, fa_center, fa_top, COLORS._main_accent);
			draw_text_add(round(_ax), round(_ay + ui(4)), overlay_label == ""? name : overlay_label);
			
		}
	}
	
	return _hover;
}