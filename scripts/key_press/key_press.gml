#region key map
	globalvar HOTKEY_MOD, HOTKEY_BLOCK, HOTKEY_ACT;
	HOTKEY_MOD   = 0;
	HOTKEY_BLOCK = false;
	HOTKEY_ACT   = false;
	
	enum MOD_KEY {
		none   = 0,
		ctrl   = 1 << 0,
		shift  = 1 << 1,
		alt    = 1 << 2
	}
	
	enum KEY_GROUP {
		base    = 10000, 
		numeric = 10001,
	}

	globalvar KEY_STRING_MAP;
	KEY_STRING_MAP = {};
	
	KEY_STRING_MAP[$ 33] = "!"
	KEY_STRING_MAP[$ 34] = "\""
	KEY_STRING_MAP[$ 35] = "#"
	KEY_STRING_MAP[$ 36] = "$"
	KEY_STRING_MAP[$ 37] = "%"
	KEY_STRING_MAP[$ 38] = "&"
	KEY_STRING_MAP[$ 39] = "'"
	KEY_STRING_MAP[$ 40] = "("
	KEY_STRING_MAP[$ 41] = ")"
	KEY_STRING_MAP[$ 42] = "*"
	KEY_STRING_MAP[$ 43] = "+"
	KEY_STRING_MAP[$ 44] = ","
	KEY_STRING_MAP[$ 45] = "-"
	KEY_STRING_MAP[$ 46] = "."
	KEY_STRING_MAP[$ 47] = "/"
	
	KEY_STRING_MAP[$ 48] = "0"
	KEY_STRING_MAP[$ 49] = "1"
	KEY_STRING_MAP[$ 50] = "2"
	KEY_STRING_MAP[$ 51] = "3"
	KEY_STRING_MAP[$ 52] = "4"
	KEY_STRING_MAP[$ 53] = "5"
	KEY_STRING_MAP[$ 54] = "6"
	KEY_STRING_MAP[$ 55] = "7"
	KEY_STRING_MAP[$ 56] = "8"
	KEY_STRING_MAP[$ 57] = "9"
	
	KEY_STRING_MAP[$ 65] = "A"
	KEY_STRING_MAP[$ 66] = "B"
	KEY_STRING_MAP[$ 67] = "C"
	KEY_STRING_MAP[$ 68] = "D"
	KEY_STRING_MAP[$ 69] = "E"
	KEY_STRING_MAP[$ 70] = "F"
	KEY_STRING_MAP[$ 71] = "G"
	KEY_STRING_MAP[$ 72] = "H"
	KEY_STRING_MAP[$ 73] = "I"
	KEY_STRING_MAP[$ 74] = "J"
	KEY_STRING_MAP[$ 75] = "K"
	KEY_STRING_MAP[$ 76] = "L"
	KEY_STRING_MAP[$ 77] = "M"
	KEY_STRING_MAP[$ 78] = "N"
	KEY_STRING_MAP[$ 79] = "O"
	KEY_STRING_MAP[$ 80] = "P"
	KEY_STRING_MAP[$ 81] = "Q"
	KEY_STRING_MAP[$ 82] = "R"
	KEY_STRING_MAP[$ 83] = "S"
	KEY_STRING_MAP[$ 84] = "T"
	KEY_STRING_MAP[$ 85] = "U"
	KEY_STRING_MAP[$ 86] = "V"
	KEY_STRING_MAP[$ 87] = "W"
	KEY_STRING_MAP[$ 88] = "X"
	KEY_STRING_MAP[$ 89] = "Y"
	KEY_STRING_MAP[$ 90] = "Z"

	KEY_STRING_MAP[$ 96]  = "Num 0"
	KEY_STRING_MAP[$ 97]  = "Num 1"
	KEY_STRING_MAP[$ 98]  = "Num 2"
	KEY_STRING_MAP[$ 99]  = "Num 3"
	KEY_STRING_MAP[$ 100] = "Num 4"
	KEY_STRING_MAP[$ 101] = "Num 5"
	KEY_STRING_MAP[$ 102] = "Num 6"
	KEY_STRING_MAP[$ 103] = "Num 7"
	KEY_STRING_MAP[$ 104] = "Num 8"
	KEY_STRING_MAP[$ 105] = "Num 9"

	KEY_STRING_MAP[$ 106] = "Num *"
	KEY_STRING_MAP[$ 107] = "Num +"
	KEY_STRING_MAP[$ 109] = "Num -"
	KEY_STRING_MAP[$ 110] = "Num ."
	KEY_STRING_MAP[$ 111] = "Num /"

	KEY_STRING_MAP[$ 186] = ";"
	KEY_STRING_MAP[$ 187] = "="
	KEY_STRING_MAP[$ 188] = ","
	KEY_STRING_MAP[$ 189] = "-"
	KEY_STRING_MAP[$ 190] = "."
	KEY_STRING_MAP[$ 191] = "/"
	KEY_STRING_MAP[$ 192] = "`" // actually `

	KEY_STRING_MAP[$ 219] = "["
	KEY_STRING_MAP[$ 220] = "\\"
	KEY_STRING_MAP[$ 221] = "]"
	KEY_STRING_MAP[$ 222] = "'" // actually # but that needs to be escaped

	KEY_STRING_MAP[$ 223] = "`" // actually ` but that needs to be escaped
	
	KEY_STRING_MAP[$ vk_space]       = "Space";
	KEY_STRING_MAP[$ vk_left]        = "Left";
	KEY_STRING_MAP[$ vk_right]       = "Right";
	KEY_STRING_MAP[$ vk_up]          = "Up";
	KEY_STRING_MAP[$ vk_down]        = "Down";
	KEY_STRING_MAP[$ vk_backspace]   = "Backspace";
	KEY_STRING_MAP[$ vk_tab]         = "Tab";
	KEY_STRING_MAP[$ vk_home]        = "Home";
	KEY_STRING_MAP[$ vk_end]         = "End";
	KEY_STRING_MAP[$ vk_delete]      = "Delete";
	KEY_STRING_MAP[$ vk_insert]      = "Insert";
	KEY_STRING_MAP[$ vk_pageup]      = "Page Up";
	KEY_STRING_MAP[$ vk_pagedown]    = "Page Down";
	KEY_STRING_MAP[$ vk_pause]       = "Pause";
	KEY_STRING_MAP[$ vk_printscreen] = "Printscreen";
	KEY_STRING_MAP[$ vk_f1]          = "F1";
	KEY_STRING_MAP[$ vk_f2]          = "F2";
	KEY_STRING_MAP[$ vk_f3]          = "F3";
	KEY_STRING_MAP[$ vk_f4]          = "F4";
	KEY_STRING_MAP[$ vk_f5]          = "F5";
	KEY_STRING_MAP[$ vk_f6]          = "F6";
	KEY_STRING_MAP[$ vk_f7]          = "F7";
	KEY_STRING_MAP[$ vk_f8]          = "F8";
	KEY_STRING_MAP[$ vk_f9]          = "F9";
	KEY_STRING_MAP[$ vk_f10]         = "F10";
	KEY_STRING_MAP[$ vk_f11]         = "F11";
	KEY_STRING_MAP[$ vk_f12]         = "F12";
	
	KEY_STRING_MAP[$ KEY_GROUP.numeric] = "0-9"
	
	globalvar KEY_STRING_KEY, KEY_ID_MAP;
	KEY_ID_MAP = {};
	KEY_STRING_KEY = struct_get_names(KEY_STRING_MAP);
	
	for( var i = 0, n = array_length(KEY_STRING_KEY); i < n; i++ ) {
		var _v = KEY_STRING_MAP[$ KEY_STRING_KEY[i]];
		KEY_ID_MAP[$ _v] = real(KEY_STRING_KEY[i]);
	}
	
#endregion

#region get 
	function key_get_index(_k) { 
		if(_k == "")      return noone;
		if(is_string(_k)) return struct_try_get(KEY_ID_MAP, _k, ord(_k)); 
		return _k;
	}
	
	function key_get_name(_key, _mod = MOD_KEY.none) {
		if(!is_numeric(_key) || (_key <= 0 && _mod == MOD_KEY.none)) return "";
		
		var dk = "";
		if(_mod & MOD_KEY.ctrl)		dk += "Ctrl+";
		if(_mod & MOD_KEY.shift)	dk += "Shift+";
		if(_mod & MOD_KEY.alt)		dk += "Alt+";
		
		if(struct_has(KEY_STRING_MAP, _key)) 
			dk += KEY_STRING_MAP[$ _key];
		else if(_key > 0) 
			dk += ansi_char(_key);	
		
		dk = string_trim_end(dk, ["+"]);
		return dk;
	}
#endregion

function key_press(_key, _mod = MOD_KEY.none, _hold = false) {
	if(WIDGET_CURRENT != undefined) return false;
	if(_mod == MOD_KEY.none && _key == noone) return false;
	
	var _modPress = HOTKEY_MOD == _mod;
	var _keyPress = false;
	
	switch(_key) {
		case KEY_GROUP.numeric : _keyPress = (keyboard_key >= ord("0") && keyboard_key <= ord("9")) || keyboard_key == ord(".") || keyboard_key == vk_backspace; break;
		
		case noone : _keyPress = true; break;
		default :    _keyPress = _hold? keyboard_check(_key) : keyboard_check_pressed(_key); break;
	}
	
	return _keyPress && _modPress;
}