#region key list
	global.KEYS_VK = [ 
		vk_left, vk_right, vk_up, vk_down, vk_space, vk_backspace, vk_tab, vk_home, vk_end, vk_delete, vk_insert, 
		vk_pageup, vk_pagedown, vk_pause, vk_printscreen, 
		vk_f1, vk_f2, vk_f3, vk_f4, vk_f5, vk_f6, vk_f7, vk_f8, vk_f9, vk_f10, vk_f11, vk_f12,
	];
#endregion

#region keyboard
	enum KEY_STAT {
		idle,
		down,
		pressing,
		up,
		
		double
	}	
	
	globalvar KEYBOARD_STRING, KEYBOARD_PRESSED;
	globalvar CTRL, ALT, SHIFT;
	
	WIDGET_ACTIVE = [];
	KEYBOARD_PRESSED = vk_nokey;
	CTRL  = KEY_STAT.idle;
	ALT   = KEY_STAT.idle;
	SHIFT = KEY_STAT.idle;
	
	function key_release() {
		INLINE
		
		CTRL  = KEY_STAT.up;	
		ALT   = KEY_STAT.up;	
		SHIFT = KEY_STAT.up;	
		
		keyboard_key_release(vk_control);
		keyboard_key_release(vk_shift);
		keyboard_key_release(vk_alt);
	}
	
	function key_mod_press_any() {
		INLINE
		return CTRL == KEY_STAT.pressing || ALT == KEY_STAT.pressing || SHIFT == KEY_STAT.pressing;
	}
	
	function key_mod_enum(key)     { INLINE 
		switch(key) {
			case MOD_KEY.alt   : return ALT;
			case MOD_KEY.shift : return SHIFT;
			case MOD_KEY.ctrl  : return CTRL;
		}
	}
	
	function key_mod_up(key)       { INLINE return key == KEY_STAT.up;       }
	function key_mod_down(key)     { INLINE return key == KEY_STAT.down;     }
	function key_mod_double(key)   { INLINE return key == KEY_STAT.double;   }
	function key_mod_press(key)    { INLINE return key == KEY_STAT.pressing; }
	function key_mod_presses(keys) { 
		INLINE 
		switch(argument_count) {
			case 1 : return argument[0] == KEY_STAT.pressing;
			case 2 : return argument[0] == KEY_STAT.pressing && argument[1] == KEY_STAT.pressing;
			case 3 : return argument[0] == KEY_STAT.pressing && argument[1] == KEY_STAT.pressing && argument[2] == KEY_STAT.pressing;
		}
		return false; 
	}
	
	function key_mod_press_index(keyindex) {
		INLINE
		
		switch(keyindex) {
			case MOD_KEY.alt   : return ALT   == KEY_STAT.pressing;
			case MOD_KEY.shift : return SHIFT == KEY_STAT.pressing;
			case MOD_KEY.ctrl  : return CTRL  == KEY_STAT.pressing;
		}
		
		return false;
	}
#endregion

#region widget
	globalvar WIDGET_CURRENT, WIDGET_ACTIVE, WIDGET_CURRENT_SCROLL;
	WIDGET_CURRENT = noone;
	WIDGET_CURRENT_SCROLL = noone;
	
	function widget_start() {
		INLINE
		
		if(array_length(WIDGET_ACTIVE) == 0) return;
		WIDGET_ACTIVE[0].activate();
	}
	
	function widget_next() {
		INLINE
		
		if(array_length(WIDGET_ACTIVE) == 0) {
			if(WIDGET_CURRENT != noone) {
				WIDGET_CURRENT.deactivate();
				WIDGET_CURRENT = noone;
			}
			return;
		}
		
		if(WIDGET_CURRENT == noone) {
			widget_start()
			return;
		}
		
		var ind = array_find(WIDGET_ACTIVE, WIDGET_CURRENT);
		WIDGET_CURRENT.deactivate();
		
		var wid = noone;
		if(ind + 1 == array_length(WIDGET_ACTIVE))
			wid = array_safe_get_fast(WIDGET_ACTIVE, 0);
		else
			wid = array_safe_get_fast(WIDGET_ACTIVE, ind + 1);
			
		if(wid) wid.activate();
	}
	
	function widget_previous() {
		if(array_length(WIDGET_ACTIVE) == 0) {
			if(WIDGET_CURRENT != noone) {
				WIDGET_CURRENT.deactivate();
				WIDGET_CURRENT = noone;
			}
			return;
		}
		
		if(WIDGET_CURRENT == noone) {
			widget_start()
			return;
		}
		
		var ind = array_find(WIDGET_ACTIVE, WIDGET_CURRENT);
		WIDGET_CURRENT.deactivate();
		
		var wid = noone;
		if(ind == 0)
			wid = array_safe_get_fast(WIDGET_ACTIVE, array_length(WIDGET_ACTIVE) - 1);
		else 
			wid = array_safe_get_fast(WIDGET_ACTIVE, ind - 1);
			
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
		
		WIDGET_CURRENT.deactivate();
		WIDGET_CURRENT = noone;
	}
	
	function widget_trigger() {
		if(WIDGET_CURRENT == noone) return;
		WIDGET_CURRENT.trigger();
	}
#endregion
