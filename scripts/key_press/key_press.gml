#region key map
	global.KEY_STRING_MAP = ds_map_create();
	
	global.KEY_STRING_MAP[?  0] = ""
	global.KEY_STRING_MAP[? 48] = "0"
	global.KEY_STRING_MAP[? 49] = "1"
	global.KEY_STRING_MAP[? 50] = "2"
	global.KEY_STRING_MAP[? 51] = "3"
	global.KEY_STRING_MAP[? 52] = "4"
	global.KEY_STRING_MAP[? 53] = "5"
	global.KEY_STRING_MAP[? 54] = "6"
	global.KEY_STRING_MAP[? 55] = "7"
	global.KEY_STRING_MAP[? 56] = "8"
	global.KEY_STRING_MAP[? 57] = "9"

	global.KEY_STRING_MAP[? 65] = "A"
	global.KEY_STRING_MAP[? 66] = "B"
	global.KEY_STRING_MAP[? 67] = "C"
	global.KEY_STRING_MAP[? 68] = "D"
	global.KEY_STRING_MAP[? 69] = "E"
	global.KEY_STRING_MAP[? 70] = "F"
	global.KEY_STRING_MAP[? 71] = "G"
	global.KEY_STRING_MAP[? 72] = "H"
	global.KEY_STRING_MAP[? 73] = "I"
	global.KEY_STRING_MAP[? 74] = "J"
	global.KEY_STRING_MAP[? 75] = "K"
	global.KEY_STRING_MAP[? 76] = "L"
	global.KEY_STRING_MAP[? 77] = "M"
	global.KEY_STRING_MAP[? 78] = "N"
	global.KEY_STRING_MAP[? 79] = "O"
	global.KEY_STRING_MAP[? 80] = "P"
	global.KEY_STRING_MAP[? 81] = "Q"
	global.KEY_STRING_MAP[? 82] = "R"
	global.KEY_STRING_MAP[? 83] = "S"
	global.KEY_STRING_MAP[? 84] = "T"
	global.KEY_STRING_MAP[? 85] = "U"
	global.KEY_STRING_MAP[? 86] = "V"
	global.KEY_STRING_MAP[? 87] = "W"
	global.KEY_STRING_MAP[? 88] = "X"
	global.KEY_STRING_MAP[? 89] = "Y"
	global.KEY_STRING_MAP[? 90] = "Z"

	global.KEY_STRING_MAP[? 96] = "Num 0"
	global.KEY_STRING_MAP[? 97] = "Num 1"
	global.KEY_STRING_MAP[? 98] = "Num 2"
	global.KEY_STRING_MAP[? 99] = "Num 3"
	global.KEY_STRING_MAP[? 100] = "Num 4"
	global.KEY_STRING_MAP[? 101] = "Num 5"
	global.KEY_STRING_MAP[? 102] = "Num 6"
	global.KEY_STRING_MAP[? 103] = "Num 7"
	global.KEY_STRING_MAP[? 104] = "Num 8"
	global.KEY_STRING_MAP[? 105] = "Num 9"

	global.KEY_STRING_MAP[? 106] = "Num *"
	global.KEY_STRING_MAP[? 107] = "Num +"
	global.KEY_STRING_MAP[? 109] = "Num -"
	global.KEY_STRING_MAP[? 110] = "Num ."
	global.KEY_STRING_MAP[? 111] = "Num /"

	global.KEY_STRING_MAP[? 186] = ";"
	global.KEY_STRING_MAP[? 187] = "="
	global.KEY_STRING_MAP[? 188] = ","
	global.KEY_STRING_MAP[? 189] = "-"
	global.KEY_STRING_MAP[? 190] = "."
	global.KEY_STRING_MAP[? 191] = "/"
	global.KEY_STRING_MAP[? 192] = "`" // actually `

	global.KEY_STRING_MAP[? 219] = "["
	global.KEY_STRING_MAP[? 220] = "\\"
	global.KEY_STRING_MAP[? 221] = "]"
	global.KEY_STRING_MAP[? 222] = "'" // actually # but that needs to be escaped

	global.KEY_STRING_MAP[? 223] = "`" // actually ` but that needs to be escaped
	
	function key_get_index(key) {
		var k = ds_map_find_first(global.KEY_STRING_MAP);
		repeat(ds_map_size(global.KEY_STRING_MAP)) {
			if(global.KEY_STRING_MAP[? k] == key) return k;
			k = ds_map_find_next(global.KEY_STRING_MAP, k);
		}
		return false;
	}
#endregion

#region get name
	function key_get_name(_key, _mod) {
		if(_key == 0 && _mod == MOD_KEY.none)
			return "";
		
		var dk = "";
		if(_mod & MOD_KEY.ctrl)		dk += "Ctrl+";
		if(_mod & MOD_KEY.shift)	dk += "Shift+";
		if(_mod & MOD_KEY.alt)		dk += "Alt+";
		
		switch(_key) {
			case vk_space : dk += "Space";	break;	
			case vk_left  : dk += "Left";	break;	
			case vk_right : dk += "Right";	break;	
			case vk_up    : dk += "Up";		break;	
			case vk_down  : dk += "Down";	break;	
			case vk_backspace :   dk += "Backspace"; break;
			case vk_tab :         dk += "Tab";		 break;
			case vk_home :        dk += "Home";		 break;
			case vk_end :         dk += "End";		 break;
			case vk_delete :      dk += "Delete";	 break;
			case vk_insert :      dk += "Insert";	 break; 
			case vk_pageup :      dk += "Page Up";	 break;
			case vk_pagedown :    dk += "Page Down"; break;
			case vk_pause :       dk += "Pause";	 break;
			case vk_printscreen : dk += "Printscreen"; break;         
			case vk_f1 :  dk += "F1"; break;
			case vk_f2 :  dk += "F2"; break;
			case vk_f3 :  dk += "F3"; break;
			case vk_f4 :  dk += "F4"; break;
			case vk_f5 :  dk += "F5"; break;
			case vk_f6 :  dk += "F6"; break;
			case vk_f7 :  dk += "F7"; break;
			case vk_f8 :  dk += "F8"; break;
			case vk_f9 :  dk += "F9"; break;
			case vk_f10 : dk += "F10"; break;
			case vk_f11 : dk += "F11"; break;
			case vk_f12 : dk += "F12"; break;          
			case -1 : break;
			default : 
				if(ds_map_exists(global.KEY_STRING_MAP, _key))
					dk += global.KEY_STRING_MAP[? _key];
				else 
					dk += ansi_char(_key);	
				break;	
		}
		
		if(string_char_at(dk, string_length(dk)) == "+")
			dk = string_copy(dk, 1, string_length(dk) - 1);
		
		return dk;
	}
#endregion

enum MOD_KEY {
	none   = 0,
	ctrl   = 1 << 0,
	shift  = 1 << 1,
	alt    = 1 << 2
}

function key_press(_key, _mod = MOD_KEY.none) {
	if(WIDGET_CURRENT) return false;
	if(_mod == MOD_KEY.none && _key == 0) return false;
	
	return keyboard_check_pressed(_key) && HOTKEY_MOD == _mod;
}