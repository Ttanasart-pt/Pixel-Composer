enum MOD_KEY {
	none   = 0,
	ctrl   = 1,
	shift  = 2,
	alt    = 4
}

function key_press(_key, _mod) {
	if(TEXTBOX_ACTIVE) return false;
	
	if(keyboard_check_released(_key) && HOTKEY_MOD == _mod)
		return true;
	return false;
}