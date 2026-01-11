#region mouse global
	globalvar CURSOR, CURSOR_SPRITE;
	globalvar CURSOR_LOCK, CURSOR_IS_LOCK, CURSOR_LOCK_X, CURSOR_LOCK_Y;
	globalvar MOUSE_WRAP, MOUSE_WRAPPING, MOUSE_BLOCK, _MOUSE_BLOCK;
	
	globalvar MOUSE_WHEEL,  MOUSE_WHEEL_H, __MOUSE_WHEEL_HOOK;
	globalvar MOUSE_PAN_X,  MOUSE_PAN_Y;
	globalvar MOUSE_ZOOM_X, MOUSE_ZOOM_Y;
	globalvar MOUSE_PAN;
	
	globalvar MOUSE_EVENT; MOUSE_EVENT = {
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
	
	#macro MOUSE_MOVED (window_mouse_get_delta_x() != 0 || window_mouse_get_delta_y() != 0)
	
	function setMouseWrap() { INLINE MOUSE_WRAP = true; }
#endregion

function mouse_step() {
	global_mouse_step();
	
	MOUSE_WHEEL      = 0;
	if(mouse_wheel_up())   MOUSE_WHEEL =  1;
	if(mouse_wheel_down()) MOUSE_WHEEL = -1;
	
	MOUSE_WHEEL_H    = 0;//mouse_wheel_get_h();
	
	// MOUSE_PAN_X   = mouse_pan_x();
	// MOUSE_PAN_Y   = mouse_pan_y();
	// MOUSE_ZOOM_X  = mouse_zoom_x();
	// MOUSE_ZOOM_Y  = mouse_zoom_y();
	
	var _focus  = window_has_focus();
	var _mouse  = _focus && point_in_rectangle(
		display_mouse_get_x(),               display_mouse_get_y(), 
		window_get_x(),                      window_get_y(), 
		window_get_x() + window_get_width(), window_get_y() + window_get_height()
	);
	
	var _fclick = !MOUSE_EVENT.wfocus && _mouse;
	
	MOUSE_EVENT.wfocus   = _focus;
	
	if(OS == os_windows) {
		MOUSE_EVENT.lclick   = _mouse && global_mouse_left_is_pressing();
		MOUSE_EVENT.lpress   = _mouse && global_mouse_left_is_pressed();
		MOUSE_EVENT.lrelease = _mouse && global_mouse_left_is_released();
		
		MOUSE_EVENT.rclick   = _mouse && global_mouse_right_is_pressing();
		MOUSE_EVENT.rpress   = _mouse && global_mouse_right_is_pressed();
		MOUSE_EVENT.rrelease = _mouse && global_mouse_right_is_released();
		
		MOUSE_EVENT.mclick   = _mouse && global_mouse_middle_is_pressing();
		MOUSE_EVENT.mpress   = _mouse && global_mouse_middle_is_pressed();
		MOUSE_EVENT.mrelease = _mouse && global_mouse_middle_is_released();
		
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
	if(PEN_RELEASED)                return true;
	
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
