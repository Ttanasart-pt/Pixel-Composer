#region mouse global
	globalvar MOUSE_WRAP, MOUSE_WRAPPING, MOUSE_BLOCK, _MOUSE_BLOCK;
	
	MOUSE_WRAP     = false;
	MOUSE_WRAPPING = false;
	MOUSE_BLOCK    = false;
	_MOUSE_BLOCK   = false;
	
	#macro SCROLL_SPEED PREFERENCES.mouse_wheel_speed
	
	function setMouseWrap() {
		INLINE
		MOUSE_WRAP = true;
	}
#endregion

function mouse_click(mouse, focus = true) {
	INLINE
	return !_MOUSE_BLOCK && focus && mouse_check_button(mouse);
}

function mouse_press(mouse, focus = true) {
	INLINE
	return !_MOUSE_BLOCK && focus && mouse_check_button_pressed(mouse);
}

function mouse_release(mouse, focus = true) {
	INLINE
	return focus && mouse_check_button_released(mouse);
}