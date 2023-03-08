function mac_window_step() {
	var _mx = mouse_raw_x;
	var _my = mouse_raw_y;
	
	if(__win_is_dragging) {
		if(__win_is_dragging == WINDOW_DRAG_MODE.move)
			window_set_position(__win_drag_sx + (_mx - __win_drag_mx), __win_drag_sy + (_my - __win_drag_my));
		else {
			if((__win_is_dragging & WINDOW_DRAG_MODE.resize_n) != 0) {
				window_set_size(__win_drag_sw, __win_drag_sh - (_my - __win_drag_my));
				window_set_position(__win_drag_sx, __win_drag_sy + (_my - __win_drag_my));
			} else if((__win_is_dragging & WINDOW_DRAG_MODE.resize_s) != 0)
				window_set_size(__win_drag_sw, __win_drag_sh + (_my - __win_drag_my));
		
			if((__win_is_dragging & WINDOW_DRAG_MODE.resize_w) != 0) {
				window_set_size(__win_drag_sw - (_mx - __win_drag_mx), __win_drag_sh);
				window_set_position(__win_drag_sx + (_mx - __win_drag_mx), __win_drag_sy);
			} else if((__win_is_dragging & WINDOW_DRAG_MODE.resize_e) != 0)
				window_set_size(__win_drag_sw + (_mx - __win_drag_mx), __win_drag_sh);
		}
		
		if(mouse_release(mb_left))
			__win_is_dragging = 0;
	}
	
	if(__win_is_dragging == 0) {
		if(point_in_rectangle(mouse_mx, mouse_my, 0, 0, ui(144), ui(40))) return;
			
		if(point_in_rectangle(mouse_mx, mouse_my, 6, 6, WIN_W - 6, ui(40))) {
			if(mouse_press(mb_left)) {
				__win_is_dragging = WINDOW_DRAG_MODE.move;
				__win_drag_mx = mouse_raw_x;
				__win_drag_my = mouse_raw_y;
				__win_drag_sx = window_get_x();
				__win_drag_sy = window_get_y();
				__win_drag_sw = window_get_width();
				__win_drag_sh = window_get_height();
			}
		} else {
			var hover = 0;
			
			if(mouse_mx > WIN_W - 6)
				hover |= WINDOW_DRAG_MODE.resize_e;
			else if(mouse_mx < 6)
				hover |= WINDOW_DRAG_MODE.resize_w;
			
			if(mouse_my > WIN_H - 6)
				hover |= WINDOW_DRAG_MODE.resize_s;
			else if(mouse_my < 6)
				hover |= WINDOW_DRAG_MODE.resize_n;
			
			if(hover == WINDOW_DRAG_MODE.resize_n || hover == WINDOW_DRAG_MODE.resize_s) 
				CURSOR = cr_size_ns;
			else if(hover == WINDOW_DRAG_MODE.resize_w || hover == WINDOW_DRAG_MODE.resize_e) 
				CURSOR = cr_size_we;
			else if(hover == (WINDOW_DRAG_MODE.resize_n | WINDOW_DRAG_MODE.resize_e))
				CURSOR = cr_size_nesw;
			else if(hover == (WINDOW_DRAG_MODE.resize_s | WINDOW_DRAG_MODE.resize_w))
				CURSOR = cr_size_nesw;
			else if(hover == (WINDOW_DRAG_MODE.resize_n | WINDOW_DRAG_MODE.resize_w))
				CURSOR = cr_size_nwse;
			else if(hover == (WINDOW_DRAG_MODE.resize_s | WINDOW_DRAG_MODE.resize_e))
				CURSOR = cr_size_nwse;
			
			if(hover > 0 && mouse_press(mb_left)) {
				__win_is_dragging = hover;
				__win_drag_mx = mouse_raw_x;
				__win_drag_my = mouse_raw_y;
				__win_drag_sx = window_get_x();
				__win_drag_sy = window_get_y();
				__win_drag_sw = window_get_width();
				__win_drag_sh = window_get_height();
			}
		}
	}
}