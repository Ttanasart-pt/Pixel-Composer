/// @description 
var trigger = false;
kb_time += DELTA_TIME;
if(kb_hkey == keyboard_lastchar && kb_hkey != "") {
	if(kb_hold && kb_time >= PREF_MAP[? "keyboard_repeat_speed"]) {
		trigger = true;
		kb_time = 0;
	} else if(!kb_hold && kb_time >= PREF_MAP[? "keyboard_repeat_start"]) {
		trigger = true;
		kb_time = 0;
		kb_hold = true;
	}
} else 
	trigger = true;

kb_hkey = keyboard_lastchar;

if(!trigger) exit;

if(keyboard_check(vk_backspace)) {
	KEYBOARD_STRING = string_copy(KEYBOARD_STRING, 1, string_length(KEYBOARD_STRING) - 1);
} else {
	KEYBOARD_STRING += keyboard_lastchar;
}