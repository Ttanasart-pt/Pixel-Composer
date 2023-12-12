#region defines
	globalvar window_resize_padding;	window_resize_padding = 6;
	globalvar window_minimize_size;		window_minimize_size  = [ 1920, 1080 ];
	globalvar window_is_maximized;		window_is_maximized   = false;
	globalvar window_is_fullscreen;		window_is_fullscreen  = false;
	globalvar window_drag_status;		window_drag_status    = 0;
	globalvar window_drag_hold;			window_drag_hold      = 0;
	globalvar window_drag_mx;			window_drag_mx        = 0;
	globalvar window_drag_my;			window_drag_my        = 0;
	globalvar window_drag_sx;			window_drag_sx        = 0;
	globalvar window_drag_sy;			window_drag_sy        = 0;
	globalvar window_drag_sw;			window_drag_sw        = 0;
	globalvar window_drag_sh;			window_drag_sh        = 0;

	globalvar window_min_w;				window_min_w = 960;
	globalvar window_min_h;				window_min_h = 600;
	
	#macro DISPLAY_REFRESH CURRENT_PANEL = panelSerialize(); display_refresh();
#endregion

function winMan_getData(curr = true) { #region
	INLINE
	var _monitors = display_measure_all();
	if(!is_array(_monitors) || array_empty(_monitors)) 
		return [ 0, 0, display_get_width(), display_get_height(), 
		         0, 0, display_get_width(), display_get_height(), ];
				 
	var _x = window_get_x();
	var _y = window_get_y();
	
	for( var i = 0, n = array_length(_monitors); i < n; i++ ) {
		var _monitor = _monitors[i];
		if(!is_array(_monitor) || array_length(_monitor) < 8) continue;
		
		if(point_in_rectangle(
			_x + WIN_W / 2, 
			_y + WIN_H / 2, 
			_monitor[0], 
			_monitor[1],
			_monitor[0] + _monitor[2], 
			_monitor[1] + _monitor[3]
		)) return _monitor;
	}
	
	return _monitors[0];
} #endregion

function winMan_setRect(_x, _y, _w, _h) { #region
	INLINE
	_w = max(window_min_w, _w);
	_h = max(window_min_h, _h);
	
	window_set_rectangle(_x, _y, _w, _h);
} #endregion

function winMan_isMinimized() { #region
	INLINE
	return gameframe_is_natively_minimized();
} #endregion

function winMan_Maximize() { #region
	INLINE
	if(gameframe_is_natively_minimized()) return;
	window_is_maximized = true;
	
	var _mon = winMan_getData();
	winMan_setRect(_mon[4], _mon[5], _mon[6], _mon[7]);
	gameframe_set_shadow(false);
} #endregion

function winMan_Unmaximize() { #region
	INLINE
	if(gameframe_is_natively_minimized()) return;
	window_is_maximized = false;
	
	var _mon = winMan_getData();
	
	winMan_setRect(
		_mon[4] + _mon[6] / 2 - window_minimize_size[0] / 2,
		_mon[5] + _mon[7] / 2 - window_minimize_size[1] / 2,
		window_minimize_size[0], 
		window_minimize_size[1]
	);
	gameframe_set_shadow(true);
} #endregion

function winMan_Minimize() { #region
	INLINE
	if(gameframe_is_natively_minimized()) return;
	gameframe_syscommand(61472);
} #endregion

function winMan_initDrag(_index) { #region
	window_drag_status = _index;
	window_drag_hold   = 0;
	window_drag_mx     = mouse_raw_x;
	window_drag_my	   = mouse_raw_y;
	window_drag_sx	   = window_get_x();
	window_drag_sy	   = window_get_y();
	window_drag_sw	   = window_get_width();
	window_drag_sh	   = window_get_height();
} #endregion

function winMan_setFullscreen(full) { #region
	if(full == window_is_fullscreen) return;
	window_is_fullscreen = full;
	
	var _mon = winMan_getData();
	if(full) {
		winMan_setRect(_mon[0], _mon[1], _mon[2], _mon[3]);
		gameframe_set_shadow(false);
	} else {
		if(window_is_maximized) winMan_Maximize();
		else					winMan_Unmaximize();
	}
	
	run_in(5, function() { DISPLAY_REFRESH });
} #endregion

function winManStep() { #region
	if(OS == os_macosx) {
		if(__win_to_dock) {
			_window_set_showborder(window_handle(), true);
			mac_minimize_to_dock(window_handle());
			__win_to_dock = false;
		} else {
			if(_window_get_showborder(window_handle()))
				_window_set_showborder(window_handle(), false);
		}
	}
	
	if(window_drag_status == 0) return;
	var _mx = window_drag_mx;
	var _my = window_drag_my;
	var _sx = window_drag_sx;
	var _sy = window_drag_sy;
	var _sw = window_drag_sw;
	var _sh = window_drag_sh;
	
	var mx = mouse_raw_x;
	var my = mouse_raw_y;
	var sx = _sx;
	var sy = _sy;
	var sw = _sw;
	var sh = _sh;
	
	if(window_drag_status & 0b10000) {
		if(window_drag_hold == 0 && window_is_maximized) {
			if(point_distance(mx, my, _mx, _my) > 8)
				window_drag_hold = 1;
		} else {
			if(window_is_maximized) {
				winMan_Unmaximize();
				window_drag_sw = window_minimize_size[0];
				window_drag_sh = window_minimize_size[1];
			} else {
				sx = _sx + (mx - _mx);
				sy = _sy + (my - _my);
				
				winMan_setRect(sx, sy, sw, sh);
			}
		}
	} else {
		if(window_drag_status & 0b0001) {
			sw = _sw + (mx - _mx);
		}
	
		if(window_drag_status & 0b0010) {
			sh = max(window_min_h, _sh - (my - _my));
			sy = _sy + (_sh - sh);
		}
	
		if(window_drag_status & 0b0100) {
			sw = max(window_min_w, _sw - (mx - _mx));
			sx = _sx + (_sw - sw);
		}
	
		if(window_drag_status & 0b1000) {
			sh = _sh + (my - _my);
		}
		
		winMan_setRect(sx, sy, sw, sh);
		
		if(mouse_release(mb_left)) {
			DISPLAY_REFRESH
		}
	}
	
	if(mouse_release(mb_left)) {
		window_minimize_size = [ sw, sh ];
		window_drag_status = 0;
	}
} #endregion

function winManDraw() { #region
	if(window_is_maximized || window_is_fullscreen) return;
	
	var pd = window_resize_padding;
	var hv = -1;
	
	var l = mouse_mx > 0 && mouse_mx < pd && mouse_my > 0 && mouse_my < WIN_H;
	var r = mouse_mx > WIN_W - pd && mouse_mx < WIN_W && mouse_my > 0 && mouse_my < WIN_H;
	var u = mouse_mx > 0 && mouse_mx < WIN_W && mouse_my > 0 && mouse_my < pd;
	var d = mouse_mx > 0 && mouse_mx < WIN_W && mouse_my > WIN_H - pd && mouse_my < WIN_H;
	
	if(r) {
		CURSOR = cr_size_we;
		hv = 0b0001;
	}
	
	if(u) {
		CURSOR = cr_size_ns;
		hv = 0b0010;
	}
	
	if(l) {
		CURSOR = cr_size_we;
		hv = 0b0100;
	}
		
	if(d) {
		CURSOR = cr_size_ns;
		hv = 0b1000;
	}
	
	if(l && u) {
		CURSOR = cr_size_nwse;
		hv = 0b0110;
	}
		
	if(r && d) {
		CURSOR = cr_size_nwse;
		hv = 0b1001;
	}
	
	if(l && d) {
		CURSOR = cr_size_nesw;
		hv = 0b1100;
	}
		
	if(r && u) {
		CURSOR = cr_size_nesw;
		hv = 0b0011;
	}
	
	if(hv > -1 && mouse_press(mb_left))
		winMan_initDrag(hv);
} #endregion