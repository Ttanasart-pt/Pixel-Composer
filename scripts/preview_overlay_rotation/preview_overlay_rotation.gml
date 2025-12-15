function preview_overlay_rotation(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _rad, _type = 0) {
	var _val  = getValue();
	var hover = -1;
	if(is_array(_val)) return hover;
	
	////- Hotkey
	
	if(preview_hotkey_active) {
		hover = 1;
		var _d0 = point_direction(_x, _y, preview_hotkey_mx, preview_hotkey_my);
		var _d1 = point_direction(_x, _y, _mx, _my);
		
		preview_hotkey_mx = _mx;
		preview_hotkey_my = _my;
		
		var _vx = _val + angle_difference(_d1, _d0);
		if(KEYBOARD_NUMBER != undefined) _vx = preview_hotkey_s + KEYBOARD_NUMBER;
		
		if(setValue(_vx)) UNDO_HOLDING = true;
		
		draw_set_color(COLORS._main_icon);
		draw_circle_prec(_x, _y, _rad, true);
		
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
	
	var _ax   = _x + lengthdir_x(_rad, _val);
	var _ay   = _y + lengthdir_y(_rad, _val);
	var index = 0;
	var _r    = ui(10);
						
	if(drag_type) {
		index = 1;
		
		var angle = point_direction(_x, _y, _mx, _my);
		if(key_mod_press(CTRL))
			angle = round(angle / 15) * 15;
								
		if(setValueInspector( angle ))
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
	
	if(index) {
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(0.5);
		draw_circle_prec(_x, _y, _rad, true);
		draw_set_alpha(1);
	}
	
	__overlay_hover = array_verify(__overlay_hover, 1);
	__overlay_hover[0] = lerp_float(__overlay_hover[0], index, 4);
	
	shader_set(sh_node_widget_rotator);
		shader_set_color("color", COLORS._main_accent);
		shader_set_i("type",      _type);
		shader_set_f("index",     __overlay_hover[0]);
		shader_set_f("angle",     degtorad(_val + 90));
		
		var _arx = _x + lengthdir_x(_rad - ui(4), _val);
		var _ary = _y + lengthdir_y(_rad - ui(4), _val);
		draw_sprite_stretched(s_fx_pixel, 0, _arx - _r * 2, _ary - _r * 2, _r * 4, _r * 4);
	shader_reset();
	
	if(overlay_draw_text) {
		draw_set_text(f_p4, fa_center, fa_bottom, COLORS._main_accent);
		draw_text_add(round(_ax), round(_ay - ui(4)), overlay_label == ""? name : overlay_label);
	}
	
	return hover;
}

function preview_overlay_rotation_range(interact, active, _x, _y, _s, _mx, _my, _snx, _sny, _rad, _type = 0) {
	var _val  = getValue();
	var hover = -1;
	
	////- Draw
	
	var index = 0;
	
	if(drag_type) {
		index = drag_type;
		
		var angle = point_direction(_x, _y, _mx, _my);
		if(key_mod_press(CTRL))
			angle = round(angle / 15) * 15;
		
		_val = [ _val[0], _val[1] ];
		_val[drag_type - 1] = angle;
			
		if(setValueInspector( _val ))
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
	
	var _r  = ui(10);
	
	for( var i = 0; i < 2; i++ ) {
		var _ax = _x + lengthdir_x(_rad, _val[i]);
		var _ay = _y + lengthdir_y(_rad, _val[i]);
		
		if(interact && point_in_circle(_mx, _my, _ax, _ay, _r)) {
			hover = 1;
			index = i + 1;
			
			if(mouse_press(mb_left, active)) {
				drag_type = i + 1;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sx   = _ax;
				drag_sy   = _ay;
			}
		} 
	}
	
	draw_set_color(COLORS._main_accent);
	if(index) {
		draw_set_alpha(0.5);
		draw_circle_prec(_x, _y, _rad, true);
		draw_set_alpha(1);
	}
	
	draw_arc_linear(_x, _y, _rad, min(_val[0], _val[1]), max(_val[0], _val[1]), 2);
	
	__overlay_hover = array_verify(__overlay_hover, 2);
	
	for( var i = 0; i < 2; i++ ) {
		__overlay_hover[i] = lerp_float(__overlay_hover[i], i + 1 == index, 4);
		
		var _ax = _x + lengthdir_x(_rad, _val[i]);
		var _ay = _y + lengthdir_y(_rad, _val[i]);
		
		draw_anchor(__overlay_hover[i], _ax, _ay, _r, 1);
	}
	
	return hover;
}