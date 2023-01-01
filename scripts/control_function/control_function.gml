#region keyboard
	enum KEYBOARD_STATUS {
		idle,
		down,
		pressing,
		up
	}	
	
	globalvar KEYBOARD_STRING, KEYBOARD_PRESSED;
	globalvar CTRL, ALT, SHIFT;
	
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