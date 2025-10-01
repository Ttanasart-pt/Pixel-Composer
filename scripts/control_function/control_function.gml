#region key list
	global.KEYS_VK = [ 
		vk_left, vk_right, vk_up, vk_down, vk_space, vk_backspace, vk_tab, vk_home, vk_end, vk_delete, vk_insert, 
		vk_pageup, vk_pagedown, vk_pause, vk_printscreen, 
		vk_f1, vk_f2, vk_f3, vk_f4, vk_f5, vk_f6, vk_f7, vk_f8, vk_f9, vk_f10, vk_f11, vk_f12,
	];
#endregion

#region keyboard
	#macro KEYBOARD_ENTER ENTER
	#macro KEYBOARD_RESET keyboard_lastchar = ""; keyboard_lastkey = -1; KEYBOARD_PRESSED_STRING = ""; KEYBOARD_STRING = "";
	#macro KEYBOARD_MOD_RESET CTRL = KEY_STAT.idle; SHIFT = KEY_STAT.idle; ALT = KEY_STAT.idle; 
		
	enum KEY_STAT {
		idle,
		down,
		pressing,
		up,
		
		double
	}	
	
	globalvar KEYBOARD_STRING, KEYBOARD_NUMBER;
	globalvar KEYBOARD_PRESSED_STRING, KEYBOARD_PRESSED;
	globalvar CTRL, ALT, SHIFT, ENTER;
	
	KEYBOARD_STRING = "";
	KEYBOARD_NUMBER = 0;
	
	WIDGET_ACTIVE = [];
	KEYBOARD_PRESSED = vk_nokey;
	CTRL  = KEY_STAT.idle;
	ALT   = KEY_STAT.idle;
	SHIFT = KEY_STAT.idle;
	ENTER = 0;
	
	function key_mod_init() {
		kb_time  = 0;
		kb_hold  = false;
		kb_hkey  = 0;
		
		kd_ctrl  = 0;
		kd_shift = 0;
		kd_alt   = 0;
		
		ENTER    = false;
	}
	
	function key_mod_step() {
		var _d = PREFERENCES.double_click_delay;
		
		kd_ctrl  += DELTA_TIME;
		kd_shift += DELTA_TIME;
		kd_alt   += DELTA_TIME;
		
		switch(CTRL) {
			case KEY_STAT.idle: 
				if(keyboard_check_pressed(vk_control)) { 
					CTRL = kd_ctrl < _d? KEY_STAT.double : KEY_STAT.down;  
					kd_ctrl = 0; 
				}
				break;
			
			case KEY_STAT.down: case KEY_STAT.double: case KEY_STAT.pressing:
				CTRL = KEY_STAT.pressing;
				if(!keyboard_check(vk_control)) CTRL = KEY_STAT.up;
				break;
				
			case KEY_STAT.up: CTRL = KEY_STAT.idle; break;
		}
		
		switch(SHIFT) {
			case KEY_STAT.idle: 
				if(keyboard_check_pressed(vk_shift)) { 
					SHIFT = kd_shift < _d? KEY_STAT.double : KEY_STAT.down;  
					kd_shift = 0; 
				}
				break;
			
			case KEY_STAT.down: case KEY_STAT.double: case KEY_STAT.pressing:
				SHIFT = KEY_STAT.pressing;
				if(!keyboard_check(vk_shift)) SHIFT = KEY_STAT.up;
				break;
				
			case KEY_STAT.up: SHIFT = KEY_STAT.idle; break;
		}
		
		switch(ALT) {
			case KEY_STAT.idle: 
				if(keyboard_check_pressed(vk_alt)) { 
					ALT = kd_alt < _d? KEY_STAT.double : KEY_STAT.down;  
					kd_alt = 0; 
				}
				break;
			
			case KEY_STAT.down: case KEY_STAT.double: case KEY_STAT.pressing:
				ALT = KEY_STAT.pressing;
				if(!keyboard_check(vk_alt)) ALT = KEY_STAT.up;
				break;
				
			case KEY_STAT.up: ALT = KEY_STAT.idle; break;
		}
		
		HOTKEY_MOD = 0;
		if(CTRL  == KEY_STAT.pressing) HOTKEY_MOD |= MOD_KEY.ctrl;
		if(SHIFT == KEY_STAT.pressing) HOTKEY_MOD |= MOD_KEY.shift;
		if(ALT   == KEY_STAT.pressing) HOTKEY_MOD |= MOD_KEY.alt;
		
		if(ENTER && !keyboard_check(vk_enter)) keyboard_lastchar = "";
		ENTER = keyboard_check_pressed(vk_enter) || ord(keyboard_lastchar) == 13;
		
		if(os_is_paused()) { KEYBOARD_MOD_RESET }
	}
	
	function key_release() {
		INLINE
		
		CTRL  = KEY_STAT.up;	
		ALT   = KEY_STAT.up;	
		SHIFT = KEY_STAT.up;	
		
		keyboard_key_release(vk_control);
		keyboard_key_release(vk_shift);
		keyboard_key_release(vk_alt);
	}
	
	function key_mod_press_any() { INLINE return CTRL == KEY_STAT.pressing || ALT == KEY_STAT.pressing || SHIFT == KEY_STAT.pressing; }
	
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
	function key_mod_check(key)    { INLINE return key == HOTKEY_MOD;        }
	
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
	globalvar WIDGET_CURRENT_SCROLL; WIDGET_CURRENT_SCROLL = undefined;
	globalvar WIDGET_CURRENT; WIDGET_CURRENT        = undefined;
	globalvar WIDGET_CURRENT_PREV; WIDGET_CURRENT_PREV   = undefined;
	globalvar WIDGET_ACTIVE; WIDGET_ACTIVE         = [];
	
	function widget_start() {
		INLINE
		
		if(array_length(WIDGET_ACTIVE) == 0) return;
		WIDGET_ACTIVE[0].activate();
	}
	
	function widget_next() {
		INLINE
		
		if(array_length(WIDGET_ACTIVE) == 0) {
			if(WIDGET_CURRENT != undefined) {
				WIDGET_CURRENT.deactivate();
				WIDGET_CURRENT = undefined;
			}
			return;
		}
		
		if(WIDGET_CURRENT == undefined) {
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
			if(WIDGET_CURRENT != undefined) {
				WIDGET_CURRENT.deactivate();
				WIDGET_CURRENT = undefined;
			}
			return;
		}
		
		if(WIDGET_CURRENT == undefined) {
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
		if(WIDGET_CURRENT == undefined) return;
		
		WIDGET_CURRENT.deactivate();
		WIDGET_CURRENT = undefined;
	}
	
	function widget_trigger() {
		if(WIDGET_CURRENT == undefined) return;
		WIDGET_CURRENT.trigger();
	}
#endregion
