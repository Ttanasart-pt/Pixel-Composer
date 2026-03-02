/// @description 
var trigger = false;

KEYBOARD_PRESSED = vk_nokey;
kb_time += DELTA_TIME;

var _rep = PREFERENCES.keyboard_repeat_speed;
switch(kb_hkey) {
	case vk_left  : 
	case vk_right : 
	case vk_up    : 
	case vk_down  : 
		_rep /= 2;
		break;
}

if(kb_hold && kb_time >= _rep) {
	trigger = true;
	kb_time = 0;
	
} else if(!kb_hold && kb_time >= PREFERENCES.keyboard_repeat_start) {
	trigger = true;
	kb_time = 0;
	kb_hold = true;
}

if(!trigger) exit;

KEYBOARD_PRESSED = kb_hkey;

if(!PREFERENCES.keyboard_capture_raw) {
	if(keyboard_check(vk_backspace)) KEYBOARD_PRESSED_STRING  = string_copy(KEYBOARD_PRESSED_STRING, 1, string_length(KEYBOARD_PRESSED_STRING) - 1);
	else                             KEYBOARD_PRESSED_STRING += keyboard_lastchar;
}

if(WIDGET_CURRENT && is(WIDGET_CURRENT, textInput))
	WIDGET_CURRENT.onKey(KEYBOARD_PRESSED);