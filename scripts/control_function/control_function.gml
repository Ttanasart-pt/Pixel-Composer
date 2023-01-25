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
	
	function widget_start() {
		if(array_length(WIDGET_ACTIVE) == 0) return;
		WIDGET_ACTIVE[0].activate();
	}
	
	function widget_next() {
		if(array_length(WIDGET_ACTIVE) == 0) return;
		if(WIDGET_CURRENT == noone) {
			widget_start()
			return;
		}
		
		var ind = array_find(WIDGET_ACTIVE, WIDGET_CURRENT);
		WIDGET_CURRENT.deactivate();
		
		var wid = noone;
		if(ind + 1 == array_length(WIDGET_ACTIVE))
			wid = array_safe_get(WIDGET_ACTIVE, 0);
		else
			wid = array_safe_get(WIDGET_ACTIVE, ind + 1);
			
		if(wid) wid.activate();
	}
	
	function widget_previous() {
		if(array_length(WIDGET_ACTIVE) == 0) return;
		if(WIDGET_CURRENT == noone) {
			widget_start()
			return;
		}
		
		var ind = array_find(WIDGET_ACTIVE, WIDGET_CURRENT);
		WIDGET_CURRENT.deactivate();
		
		var wid = noone;
		if(ind == 0)
			wid = array_safe_get(WIDGET_ACTIVE, array_length(WIDGET_ACTIVE) - 1);
		else 
			wid = array_safe_get(WIDGET_ACTIVE, ind - 1);
			
		if(wid) wid.activate();
	}
	
	function widget_set(_widget) {
		if(array_length(WIDGET_ACTIVE) == 0) return;
		
		if(WIDGET_CURRENT) {
			var ind = array_find(WIDGET_ACTIVE, WIDGET_CURRENT);
			WIDGET_CURRENT.deactivate();
		}
		
		_widget.activate();
	}
	
	function widget_clear() {
		if(WIDGET_CURRENT == noone) return;
		if(array_length(WIDGET_ACTIVE) == 0) return;
		
		var ind = array_find(WIDGET_ACTIVE, WIDGET_CURRENT);
		WIDGET_CURRENT.deactivate();
		WIDGET_CURRENT = noone;
	}
	
	function widget_trigger() {
		if(WIDGET_CURRENT == noone) return;
		WIDGET_CURRENT.trigger();
	}
#endregion
