/// @description 
var trigger = false;

KEYBOARD_PRESSED = vk_nokey;
kb_time += DELTA_TIME;
if(kb_hold && kb_time >= PREFERENCES.keyboard_repeat_speed) {
	trigger = true;
	kb_time = 0;
} else if(!kb_hold && kb_time >= PREFERENCES.keyboard_repeat_start) {
	trigger = true;
	kb_time = 0;
	kb_hold = true;
}

if(!trigger) exit;

KEYBOARD_PRESSED = kb_hkey;

if(keyboard_check(vk_backspace))
	KEYBOARD_STRING = string_copy(KEYBOARD_STRING, 1, string_length(KEYBOARD_STRING) - 1);
else
	KEYBOARD_STRING += keyboard_lastchar;
	
if(WIDGET_CURRENT && is_instanceof(WIDGET_CURRENT, textInput))
	WIDGET_CURRENT.onKey(KEYBOARD_PRESSED);