#region mouse global
	globalvar CURSOR, CURSOR_LOCK, CURSOR_IS_LOCK, CURSOR_LOCK_X, CURSOR_LOCK_Y;
	globalvar MOUSE_WRAP, MOUSE_WRAPPING, MOUSE_BLOCK, _MOUSE_BLOCK;
	globalvar MOUSE_POOL;
	
	MOUSE_WRAP     = false;
	MOUSE_WRAPPING = false;
	MOUSE_BLOCK    = false;
	_MOUSE_BLOCK   = false;
	PEN_RELEASED   = false;
	MOUSE_POOL = {
		lclick: false, lpress: false, lrelease: false,
		rclick: false, rpress: false, rrelease: false,
		mclick: false, mpress: false, mrelease: false,
	}
	
	#macro SCROLL_SPEED PREFERENCES.mouse_wheel_speed
	#macro MOUSE_MOVED (window_mouse_get_delta_x() || window_mouse_get_delta_y())
	
	#macro   mouse_wheel_up mouse_wheel_up_override
	#macro __mouse_wheel_up mouse_wheel_up
	
	#macro   mouse_wheel_down mouse_wheel_down_override
	#macro __mouse_wheel_down mouse_wheel_down
	
	function setMouseWrap() {
		INLINE
		MOUSE_WRAP = true;
	}
#endregion

function global_mouse_pool_init() {
	MOUSE_POOL.lclick = mouse_check_button(mb_left);
	MOUSE_POOL.rclick = mouse_check_button(mb_right);
	MOUSE_POOL.mclick = mouse_check_button(mb_middle);
	
	MOUSE_POOL.lpress = mouse_check_button_pressed(mb_left);
	MOUSE_POOL.rpress = mouse_check_button_pressed(mb_right);
	MOUSE_POOL.mpress = mouse_check_button_pressed(mb_middle);
	
	MOUSE_POOL.lrelease = mouse_check_button_released(mb_left);
	MOUSE_POOL.rrelease = mouse_check_button_released(mb_right);
	MOUSE_POOL.mrelease = mouse_check_button_released(mb_middle);

	for( var i = 0, n = array_length(global.winwin_all); i < n; i++ ) {
		var ww = global.winwin_all[i];
		if(!__ww_valid) continue;
		
		MOUSE_POOL.lclick |= winwin_mouse_check_button(ww, mb_left);
		MOUSE_POOL.rclick |= winwin_mouse_check_button(ww, mb_right);
		MOUSE_POOL.mclick |= winwin_mouse_check_button(ww, mb_middle);
		
		MOUSE_POOL.lpress |= winwin_mouse_check_button_pressed(ww, mb_left);
		MOUSE_POOL.rpress |= winwin_mouse_check_button_pressed(ww, mb_right);
		MOUSE_POOL.mpress |= winwin_mouse_check_button_pressed(ww, mb_middle);
		
		MOUSE_POOL.lrelease |= winwin_mouse_check_button_released(ww, mb_left);
		MOUSE_POOL.rrelease |= winwin_mouse_check_button_released(ww, mb_right);
		MOUSE_POOL.mrelease |= winwin_mouse_check_button_released(ww, mb_middle);
	}
}

function mouse_click(mouse, focus = true) {
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	
	if(PEN_RIGHT_CLICK) return mouse == mb_right;
	
	return WINDOW_ACTIVE == noone? mouse_check_button(mouse) : winwin_mouse_check_button_safe(WINDOW_ACTIVE, mouse);
}

function mouse_press(mouse, focus = true) {
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	
	if(PEN_RIGHT_PRESS) return mouse == mb_right;
	
	if(WINDOW_ACTIVE == noone) return mouse_check_button_pressed(mouse);
	if(mouse != mb_any)        return winwin_mouse_check_button_pressed_safe(WINDOW_ACTIVE, mouse);
	
	return winwin_mouse_check_button_pressed_safe(WINDOW_ACTIVE, mb_left) || winwin_mouse_check_button_pressed_safe(WINDOW_ACTIVE, mb_right);
}

function mouse_release(mouse, focus = true) {
	INLINE
	if(!focus)			return false;
	
	if(PEN_RIGHT_RELEASE) return mouse == mb_right;
	
	var rl = WINDOW_ACTIVE == noone? mouse_check_button_released(mouse) : winwin_mouse_check_button_released_safe(WINDOW_ACTIVE, mouse);
	return rl || ((mouse == mb_left || mouse == mb_any) && PEN_RELEASED);
}

function mouse_lclick(focus = true) {
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	if(PEN_RIGHT_CLICK || PEN_RIGHT_RELEASE) return false;
	
	return WINDOW_ACTIVE == noone? mouse_check_button(mb_left) : winwin_mouse_check_button_safe(WINDOW_ACTIVE, mb_left);
}

function mouse_lpress(focus = true) {
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	if(PEN_RIGHT_PRESS) return false;
	
	return WINDOW_ACTIVE == noone? mouse_check_button_pressed(mb_left) : winwin_mouse_check_button_pressed_safe(WINDOW_ACTIVE, mb_left);
}

function mouse_lrelease(focus = true) {
	INLINE
	if(!focus)			  return false;
	if(PEN_RIGHT_RELEASE) return false;
	if(PEN_RELEASED)	  return true;
	
	return WINDOW_ACTIVE == noone? mouse_check_button_released(mb_left) : winwin_mouse_check_button_released_safe(WINDOW_ACTIVE, mb_left);
}

function mouse_rclick(focus = true) {
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	if(PEN_RIGHT_CLICK) return true;
	
	return WINDOW_ACTIVE == noone? mouse_check_button(mb_right) : winwin_mouse_check_button_safe(WINDOW_ACTIVE, mb_right);
}

function mouse_rpress(focus = true) {
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	if(PEN_RIGHT_PRESS) return true;
	
	return WINDOW_ACTIVE == noone? mouse_check_button_pressed(mb_right) : winwin_mouse_check_button_pressed_safe(WINDOW_ACTIVE, mb_right);
}

function mouse_rrelease(focus = true) {
	INLINE
	if(!focus)			  return false;
	if(PEN_RIGHT_RELEASE) return true;
	
	return WINDOW_ACTIVE == noone? mouse_check_button_released(mb_right) : winwin_mouse_check_button_released_safe(WINDOW_ACTIVE, mb_right);
}
	
function mouse_lock(mx = CURSOR_LOCK_X, my = CURSOR_LOCK_Y) {
	INLINE 
	
	CURSOR_LOCK   = true;
	CURSOR_LOCK_X = mx;
	CURSOR_LOCK_Y = my;
	
	window_mouse_set(CURSOR_LOCK_X, CURSOR_LOCK_Y);
}

function mouse_wheel_up_override()   { return (WINDOW_ACTIVE != noone && winwin_exists(WINDOW_ACTIVE))? winwin_mouse_wheel_up(WINDOW_ACTIVE)   : __mouse_wheel_up();   }
function mouse_wheel_down_override() { return (WINDOW_ACTIVE != noone && winwin_exists(WINDOW_ACTIVE))? winwin_mouse_wheel_down(WINDOW_ACTIVE) : __mouse_wheel_down(); }