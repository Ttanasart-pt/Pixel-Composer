#region mouse global
	globalvar MOUSE_WRAP, MOUSE_WRAPPING, MOUSE_BLOCK, _MOUSE_BLOCK;
	
	MOUSE_WRAP     = false;
	MOUSE_WRAPPING = false;
	MOUSE_BLOCK    = false;
	_MOUSE_BLOCK   = false;
	PEN_RELEASED = false;
	
	#macro SCROLL_SPEED PREFERENCES.mouse_wheel_speed
	
	function setMouseWrap() {
		INLINE
		MOUSE_WRAP = true;
	}
#endregion

function mouse_click(mouse, focus = true) { #region
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	
	if(PEN_RIGHT_CLICK) return mouse == mb_right;
	
	return mouse_check_button(mouse);
} #endregion

function mouse_press(mouse, focus = true) { #region
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	
	if(PEN_RIGHT_PRESS) return mouse == mb_right;
	
	return mouse_check_button_pressed(mouse);
} #endregion

function mouse_release(mouse, focus = true) { #region
	INLINE
	if(!focus)			return false;
	
	if(PEN_RIGHT_RELEASE) return mouse == mb_right;
	
	return mouse_check_button_released(mouse) || (mouse == mb_left && PEN_RELEASED);
} #endregion

function mouse_lclick(focus = true) { #region
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	if(PEN_RIGHT_CLICK || PEN_RIGHT_RELEASE) return false;
	
	return mouse_check_button(mb_left);
} #endregion

function mouse_lpress(focus = true) { #region
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	if(PEN_RIGHT_PRESS) return false;
	
	return mouse_check_button_pressed(mb_left);
} #endregion

function mouse_lrelease(focus = true) { #region
	INLINE
	if(!focus)			  return false;
	if(PEN_RIGHT_RELEASE) return false;
	if(PEN_RELEASED)	  return true;
	
	return mouse_check_button_released(mb_left);
} #endregion

function mouse_rclick(focus = true) { #region
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	if(PEN_RIGHT_CLICK) return true;
	
	return mouse_check_button(mb_right);
} #endregion

function mouse_rpress(focus = true) { #region
	INLINE
	if(MOUSE_BLOCK)		return false;
	if(!focus)			return false;
	if(PEN_RIGHT_PRESS) return true;
	
	return mouse_check_button_pressed(mb_right);
} #endregion

function mouse_rrelease(focus = true) { #region
	INLINE
	if(!focus)			  return false;
	if(PEN_RIGHT_RELEASE) return true;
	
	return mouse_check_button_released(mb_right);
} #endregion