#region keyboard
	enum KEYBOARD_STATUS {
		idle,
		down,
		pressing,
		up
	}	
	
	globalvar KEYBOARD_STRING, KEYBOARD_PRESSED;
	globalvar CTRL, ALT, SHIFT;
	
	WIDGET_ACTIVE = [];
	KEYBOARD_PRESSED = vk_nokey;
	CTRL  = KEYBOARD_STATUS.idle;
	ALT   = KEYBOARD_STATUS.idle;
	SHIFT = KEYBOARD_STATUS.idle;
	
	function key_release() {
		CTRL  = KEYBOARD_STATUS.up;	
		ALT   = KEYBOARD_STATUS.up;	
		SHIFT = KEYBOARD_STATUS.up;	
		
		keyboard_key_release(vk_control);
		keyboard_key_release(vk_shift);
		keyboard_key_release(vk_alt);
	}
	
	function key_mod_press(key) {
		return key == KEYBOARD_STATUS.pressing;
	}
#endregion

#region widget
	globalvar WIDGET_CURRENT, WIDGET_ACTIVE, WIDGET_CURRENT_SCROLL;
	WIDGET_CURRENT = noone;
	WIDGET_CURRENT_SCROLL = noone;
	
	function widget_next() {
		if(WIDGET_CURRENT == noone) return;
		if(array_length(WIDGET_ACTIVE) == 0) return;
		
		var ind = array_find(WIDGET_ACTIVE, WIDGET_CURRENT);
		WIDGET_CURRENT.deactivate();
		
		if(ind + 1 == array_length(WIDGET_ACTIVE))
			WIDGET_ACTIVE[0].activate();
		else 
			WIDGET_ACTIVE[ind + 1].activate();
	}
	
	function widget_previous() {
		if(WIDGET_CURRENT == noone) return;
		if(array_length(WIDGET_ACTIVE) == 0) return;
		
		var ind = array_find(WIDGET_ACTIVE, WIDGET_CURRENT);
		WIDGET_CURRENT.deactivate();
		
		if(ind == 0)
			WIDGET_ACTIVE[array_length(WIDGET_ACTIVE) - 1].activate();
		else 
			WIDGET_ACTIVE[ind - 1].activate();
	}
	
	function widget_trigger() {
		if(WIDGET_CURRENT == noone) return;
		WIDGET_CURRENT.trigger();
	}
#endregion
