/// @description 
kb_hkey = vk_nokey;
if(kb_hkey < 0 && keyboard_key     > 0) kb_hkey = keyboard_key;
if(kb_hkey < 0 && keyboard_lastkey > 0) kb_hkey = keyboard_lastkey;

if(kb_hkey <= 0 && PREFERENCES.keyboard_check_sweep) for(var i = 2; i < 320; i++) if(keyboard_check_pressed(i)) { kb_hkey = i; break; }

kb_time = 0;
kb_hold = false;

KEYBOARD_PRESSED = kb_hkey;

if(!PREFERENCES.keyboard_capture_raw) {
	if(keyboard_check(vk_backspace)) KEYBOARD_PRESSED_STRING  = string_copy(KEYBOARD_PRESSED_STRING, 1, string_length(KEYBOARD_PRESSED_STRING) - 1);
	else                             KEYBOARD_PRESSED_STRING += keyboard_lastchar;
}

if(KEYBOARD_PRESSED == -1) {
	for( var i = 0, n = array_length(global.KEYS_VK); i < n; i++ ) {
		if(keyboard_check(global.KEYS_VK[i]))
			KEYBOARD_PRESSED = global.KEYS_VK[i];
	}
}