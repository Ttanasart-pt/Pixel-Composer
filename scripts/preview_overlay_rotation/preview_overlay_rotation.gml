function preview_overlay_rotation(active, _x, _y, _s, _mx, _my, _snx, _sny, _rad) {
	var _val = getValue();
	var hover = -1;
	if(is_array(_val)) return hover;
	
	var _ax = _x + lengthdir_x(_rad, _val);
	var _ay = _y + lengthdir_y(_rad, _val);
	draw_sprite_ui(THEME.anchor_rotate, 0, _ax, _ay, 1, 1, _val - 90, c_white, 1);
						
	if(drag_type) {
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(0.5);
		draw_circle(_x, _y, _rad, true);
		draw_set_alpha(1);
							
		draw_sprite_ui(THEME.anchor_rotate, 1, _ax, _ay, 1, 1, _val - 90, c_white, 1);
		var angle = point_direction(_x, _y, _mx, _my);
		if(key_mod_press(CTRL))
			angle = round(angle / 15) * 15;
								
		if(setValue( angle ))
			UNDO_HOLDING = true;
							
		if(mouse_release(mb_left)) {
			drag_type = 0;
			UNDO_HOLDING = false;
		}
	}
						
	if(point_in_circle(_mx, _my, _ax, _ay, 8)) {
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(0.5);
		draw_circle(_x, _y, _rad, true);
		draw_set_alpha(1);
		hover = 1;
							
		draw_sprite_ui(THEME.anchor_rotate, 1, _ax, _ay, 1, 1, _val - 90, c_white, 1);
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