#region mouse global
	globalvar CURSOR, CURSOR_SPRITE;
	globalvar CURSOR_LOCK, CURSOR_IS_LOCK, CURSOR_LOCK_X, CURSOR_LOCK_Y;
	globalvar MOUSE_WRAP, MOUSE_WRAPPING, MOUSE_BLOCK, _MOUSE_BLOCK;
	
	globalvar MOUSE_WHEEL,  MOUSE_WHEEL_H, __MOUSE_WHEEL_HOOK;
	globalvar MOUSE_PAN_X,  MOUSE_PAN_Y;
	globalvar MOUSE_ZOOM_X, MOUSE_ZOOM_Y;
	globalvar MOUSE_PAN;
	
	globalvar MOUSE_GLOBAL; MOUSE_GLOBAL = extension_exists("winMan"); show_debug_message($"winMan Stat: {MOUSE_GLOBAL}");
	globalvar MOUSE_EVENT; MOUSE_EVENT  = {
		wfocus: window_has_focus(),
		lclick: false, lpress: false, lrelease: false, toPress: false, 
		rclick: false, rpress: false, rrelease: false,
		mclick: false, mpress: false, mrelease: false,
	}
	
	CURSOR_SPRITE  = noone;
	MOUSE_WRAP     = false;
	MOUSE_WRAPPING = false;
	MOUSE_BLOCK    = false;
	_MOUSE_BLOCK   = false;
	PEN_RELEASED   = false;
	
	MOUSE_WHEEL      = 0;
	MOUSE_WHEEL_H    = 0;
	__MOUSE_WHEEL_HOOK = false;
	
	MOUSE_PAN_X   = 0;
	MOUSE_PAN_Y   = 0;
	MOUSE_ZOOM_X  = 0;
	MOUSE_ZOOM_Y  = 0;
	MOUSE_PAN     = true;
#endregion

#region mouse position.
	function MOUSE_X() {
		switch(OS) {
			case os_windows : 
				if(PEN_USE) return PEN_X;
				if(winwin_exists(WINWIN_CURRENT)) 
					return display_mouse_get_x() - winwin_get_x(WINWIN_CURRENT);
				return display_mouse_get_x() - WIN_X;
				
			case os_linux : 
				return display_mouse_get_x() - WIN_X;
				
			case os_macosx : 
				return display_mouse_get_x();
		}
		
		return 0;
	}
	
	function MOUSE_Y() {
		switch(OS) {
			case os_windows : 
				if(PEN_USE) return PEN_Y;
				if(winwin_exists(WINWIN_CURRENT)) 
					return display_mouse_get_y() - winwin_get_y(WINWIN_CURRENT);
				return display_mouse_get_y() - WIN_Y;
		
			case os_linux : 
				return display_mouse_get_y() - WIN_Y;
				
			case os_macosx : 
				return display_mouse_get_y();
		}
		
		return 0;
	}
	
	#macro mouse_mx MOUSE_X()
	#macro mouse_my MOUSE_Y()
	#macro mouse_ui [mouse_mx, mouse_my]
	
	#macro mouse_mxs (FILE_IS_DROPPING? FILE_DROPPING_X : mouse_mx)
	#macro mouse_mys (FILE_IS_DROPPING? FILE_DROPPING_Y : mouse_my)
	
	#macro mouse_rx display_mouse_get_x()
	#macro mouse_ry display_mouse_get_y()
	
	#macro MOUSE_MOVED (window_mouse_get_delta_x() != 0 || window_mouse_get_delta_y() != 0)
	
	function setMouseWrap() { INLINE MOUSE_WRAP = true; }
#endregion

function mouse_step() {
	if(MOUSE_GLOBAL) global_mouse_step();
	
	MOUSE_WHEEL      = 0;
	if(mouse_wheel_up())   MOUSE_WHEEL =  1 * PREFERENCES.mouse_wheel_speed;
	if(mouse_wheel_down()) MOUSE_WHEEL = -1 * PREFERENCES.mouse_wheel_speed;
	
	MOUSE_WHEEL_H    = 0; // mouse_wheel_get_h();
	
	// MOUSE_PAN_X   = mouse_pan_x();
	// MOUSE_PAN_Y   = mouse_pan_y();
	// MOUSE_ZOOM_X  = mouse_zoom_x();
	// MOUSE_ZOOM_Y  = mouse_zoom_y();
	
	var _focus  = window_has_focus();
	var _mouse  = _focus && point_in_rectangle(
		mouse_rx,                            mouse_ry, 
		WIN_X,                      WIN_Y, 
		WIN_X + window_get_width(), WIN_Y + window_get_height()
	);
	
	if(MULTI_WINDOWS) _mouse = FOCUS_WINDOW != undefined;
	
	var _fclick = !MOUSE_EVENT.wfocus && _mouse;
	MOUSE_EVENT.wfocus = _focus;
	
	if(OS == os_windows && MOUSE_GLOBAL) {
		MOUSE_EVENT.lclick   = _mouse && global_mouse_left_is_pressing();
		MOUSE_EVENT.lpress   = _mouse && global_mouse_left_is_pressed();
		MOUSE_EVENT.lrelease = global_mouse_left_is_released();
		
		MOUSE_EVENT.rclick   = _mouse && global_mouse_right_is_pressing();
		MOUSE_EVENT.rpress   = _mouse && global_mouse_right_is_pressed();
		MOUSE_EVENT.rrelease = global_mouse_right_is_released();
		
		MOUSE_EVENT.mclick   = _mouse && global_mouse_middle_is_pressing();
		MOUSE_EVENT.mpress   = _mouse && global_mouse_middle_is_pressed();
		MOUSE_EVENT.mrelease = global_mouse_middle_is_released();
		
		for( var i = 0, n = array_length(WINWIN_ALL); i < n; i++ ) {
			var win = WINWIN_ALL[i];
			
			MOUSE_EVENT.lclick   |= winwin_mouse_check_button(          win, mb_left   );
			MOUSE_EVENT.lpress   |= winwin_mouse_check_button_pressed(  win, mb_left   );
			MOUSE_EVENT.lrelease |= winwin_mouse_check_button_released( win, mb_left   );
			
			MOUSE_EVENT.rclick   |= winwin_mouse_check_button(          win, mb_right  );
			MOUSE_EVENT.rpress   |= winwin_mouse_check_button_pressed(  win, mb_right  );
			MOUSE_EVENT.rrelease |= winwin_mouse_check_button_released( win, mb_right  );
			
			MOUSE_EVENT.mclick   |= winwin_mouse_check_button(          win, mb_middle );
			MOUSE_EVENT.mpress   |= winwin_mouse_check_button_pressed(  win, mb_middle );
			MOUSE_EVENT.mrelease |= winwin_mouse_check_button_released( win, mb_middle );
			
			if(winwin_mouse_wheel_up(win))   MOUSE_WHEEL =  1;
			if(winwin_mouse_wheel_down(win)) MOUSE_WHEEL = -1;
		}
		
	} else {
		MOUSE_EVENT.lclick   = mouse_check_button(mb_left);
		MOUSE_EVENT.rclick   = mouse_check_button(mb_right);
		MOUSE_EVENT.mclick   = mouse_check_button(mb_middle);
		
		MOUSE_EVENT.lpress   = mouse_check_button_pressed(mb_left);
		MOUSE_EVENT.rpress   = mouse_check_button_pressed(mb_right);
		MOUSE_EVENT.mpress   = mouse_check_button_pressed(mb_middle);
		
		MOUSE_EVENT.lrelease = mouse_check_button_released(mb_left);
		MOUSE_EVENT.rrelease = mouse_check_button_released(mb_right);
		MOUSE_EVENT.mrelease = mouse_check_button_released(mb_middle);
		
		if(MOUSE_EVENT.toPress) {
			if(MOUSE_EVENT.lrelease) {
				MOUSE_EVENT.lclick   = true;
				MOUSE_EVENT.lpress   = true;
				MOUSE_EVENT.lrelease = false;
			}
		}
		
	}
	
	if(MOUSE_EVENT.toPress) MOUSE_EVENT.toPress--;
	else MOUSE_EVENT.toPress = _fclick;
}

function mouse_click(mouse, focus = true, bypass = false) {
	INLINE
	if((!bypass && MOUSE_BLOCK) || !focus) return false;
	if(PEN_RIGHT_CLICK)                    return mouse == mb_right;
	
	switch(mouse) {
		case mb_left   : return PEN_CONTACT || MOUSE_EVENT.lclick;
		case mb_middle : return MOUSE_EVENT.mclick;
		case mb_right  : return MOUSE_EVENT.rclick;
		case mb_any    : return PEN_CONTACT || MOUSE_EVENT.lclick || MOUSE_EVENT.rclick || MOUSE_EVENT.mclick;
	}
	
	return false;
}

function mouse_press(mouse, focus = true, bypass = false) {
	INLINE
	if((!bypass && MOUSE_BLOCK) || !focus) return false;
	if(PEN_RIGHT_PRESS)                    return mouse == mb_right;
	
	switch(mouse) {
		case mb_left   : return PEN_PRESSED || MOUSE_EVENT.lpress;
		case mb_middle : return MOUSE_EVENT.mpress;
		case mb_right  : return MOUSE_EVENT.rpress;
		case mb_any    : return PEN_PRESSED || MOUSE_EVENT.lpress || MOUSE_EVENT.rpress || MOUSE_EVENT.mpress;
	}
	
	return false;
}

function mouse_release(mouse, focus = true, bypass = false) {
	INLINE
	// if((!bypass && MOUSE_BLOCK) || !focus) return false;
	if(!focus)                             return false;
	if(PEN_RIGHT_RELEASE)                  return mouse == mb_right;
	
	var rl = false;
	switch(mouse) {
		case mb_left   : rl = PEN_RELEASED || MOUSE_EVENT.lrelease;                                 break;
		case mb_middle : rl = MOUSE_EVENT.mrelease;                                                 break;
		case mb_right  : rl = MOUSE_EVENT.rrelease;                                                 break;
		case mb_any    : rl = PEN_RELEASED || MOUSE_EVENT.lrelease || MOUSE_EVENT.rrelease || MOUSE_EVENT.mrelease; break;
	}
	
	return rl || ((mouse == mb_left || mouse == mb_any) && PEN_RELEASED);
}

function mouse_lclick(focus = true, bypass = false) {
	INLINE
	if((!bypass && MOUSE_BLOCK) || !focus)   return false;
	if(PEN_RIGHT_CLICK || PEN_RIGHT_RELEASE) return false;
	
	return PEN_CONTACT || MOUSE_EVENT.lclick;
}

function mouse_lpress(focus = true, bypass = false) {
	INLINE
	if((!bypass && MOUSE_BLOCK) || !focus) return false;
	if(PEN_RIGHT_PRESS)                    return false;
	
	return PEN_PRESSED || MOUSE_EVENT.lpress;
}

function mouse_lrelease(focus = true, bypass = false) {
	INLINE
	if(!focus || PEN_RIGHT_RELEASE) return false;
	
	return PEN_RELEASED || MOUSE_EVENT.lrelease;
}

function mouse_rclick(focus = true, bypass = false) {
	INLINE
	if((!bypass && MOUSE_BLOCK) || !focus) return false;
	if(PEN_RIGHT_CLICK)                    return true;
	
	return MOUSE_EVENT.rclick;
}

function mouse_rpress(focus = true, bypass = false) {
	INLINE
	if((!bypass && MOUSE_BLOCK) || !focus) return false;
	if(PEN_RIGHT_PRESS)                    return true;
	
	return MOUSE_EVENT.rpress;
}

function mouse_rrelease(focus = true, bypass = false) {
	INLINE
	if(!focus)			  return false;
	if(PEN_RIGHT_RELEASE) return true;
	
	return MOUSE_EVENT.rrelease;
}
	
function mouse_lock(mx = CURSOR_LOCK_X, my = CURSOR_LOCK_Y) {
	INLINE 
	
	CURSOR_LOCK   = true;
	CURSOR_LOCK_X = mx;
	CURSOR_LOCK_Y = my;
	
	window_mouse_set(CURSOR_LOCK_X, CURSOR_LOCK_Y);
}
