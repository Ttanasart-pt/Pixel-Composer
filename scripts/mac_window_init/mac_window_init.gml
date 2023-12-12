enum WINDOW_DRAG_MODE {
	_move    = 1 << 0,
	resize_n = 1 << 1,
	resize_e = 1 << 2,
	resize_s = 1 << 3,
	resize_w = 1 << 4,
}

function mac_window_init() {
	globalvar __win_is_maximized, __win_min_x, __win_min_y, __win_min_w, __win_min_h;
	
	__win_delay = 2;
	__win_is_dragging = 0;
	__win_drag_mx = 0;
	__win_drag_my = 0;
	__win_drag_sx = 0;
	__win_drag_sy = 0;
	__win_drag_sw = 0;
	__win_drag_sh = 0;
	
	__win_to_dock = false;
	
	__win_is_maximized = false;
	__win_min_x = 0;
	__win_min_y = 0;
	__win_min_w = 0;
	__win_min_h = 0;
	
	_window_set_showborder(window_handle(), false);
}

function mac_window_maximize() {
	if(__win_is_maximized) return;
	
	__win_is_maximized = true;
	__win_min_x = window_get_x();
	__win_min_y = window_get_y();
	__win_min_w = window_get_width();
	__win_min_h = window_get_height();
	
	var _w = display_get_width();
	var _h = display_get_height();
	
	room_width  = _w;
	room_height = _h;
		
	display_set_gui_size(_w, _h);
	winMan_setRect(0, 0, _w, _h);
	
	display_refresh();
}

function mac_window_minimize() {
	if(!__win_is_maximized) return;
	
	__win_is_maximized = false;
	
	winMan_setRect(__win_min_x, __win_min_y, __win_min_w, __win_min_h);
	display_refresh();
}

function mac_window_dock() {
	o_main.__win_to_dock = true;
}