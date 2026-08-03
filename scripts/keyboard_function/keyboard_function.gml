#macro keyboard_check keyboard_check_winwin
#macro __keyboard_check keyboard_check
function keyboard_check_winwin(_key) {
	return is_winwin(WINWIN_CURRENT)? winwin_keyboard_check(WINWIN_CURRENT, _key) : __keyboard_check(_key);
}

#macro keyboard_check_pressed keyboard_check_pressed_winwin
#macro __keyboard_check_pressed keyboard_check_pressed
function keyboard_check_pressed_winwin(_key) {
	return is_winwin(WINWIN_CURRENT)? winwin_keyboard_check_pressed(WINWIN_CURRENT, _key) : __keyboard_check_pressed(_key);
}

#macro keyboard_check_released keyboard_check_released_winwin
#macro __keyboard_check_released keyboard_check_released
function keyboard_check_released_winwin(_key) {
	return is_winwin(WINWIN_CURRENT)? winwin_keyboard_check_released(WINWIN_CURRENT, _key) : __keyboard_check_released(_key);
}
