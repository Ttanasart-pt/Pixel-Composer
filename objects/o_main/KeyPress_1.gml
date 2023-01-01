/// @description 
kb_hkey = keyboard_key;
kb_time = 0;
kb_hold = false;

KEYBOARD_PRESSED = kb_hkey;

if(keyboard_check(vk_backspace))
	KEYBOARD_STRING = string_copy(KEYBOARD_STRING, 1, string_length(KEYBOARD_STRING) - 1);
else
	KEYBOARD_STRING += keyboard_lastchar;