#region data
	globalvar PREF_MAP;
	PREF_MAP = ds_map_create();
#endregion

#region pref map
	PREF_MAP[? "part_max_amount"] = 256;
	PREF_MAP[? "path_resolution"] = 32;
	
	PREF_MAP[? "double_click_delay"] = 12;
	
	PREF_MAP[? "show_splash"] = true;
	
	PREF_MAP[? "display_scaling"] = 1;
	
	PREF_MAP[? "window_width"]		= 1600;
	PREF_MAP[? "window_height"]		= 800;
	PREF_MAP[? "window_maximize"]	= false;
	
	PREF_MAP[? "curve_connection_line"]	= true;
	
	PREF_MAP[? "default_surface_side"]	= 32;
	
	PREF_MAP[? "panel_layout"] = 1;
	PREF_MAP[? "panel_collection"] = true;
	
	PREF_MAP[? "inspector_line_break_width"] = 500;
	
	PREF_MAP[? "node_show_time"] = true;
	
	PREF_MAP[? "shape_separation_max"] = 32;
	PREF_MAP[? "level_resolution"] = 64;
	PREF_MAP[? "level_max_sampling"] = 32;
	PREF_MAP[? "verlet_iteration"] = 4;
	
	PREF_MAP[? "collection_preview_speed"] = 60;
#endregion

#region hotkeys	
	function hotkeyObject(_context, _name, _key, _mod, _action) constructor {
		context	= _context;
		name	= _name;
		key		= _key;
		modi	= _mod;
		action	= _action;
		
		static serialize = function() {
			var ll = ds_list_create();
			ll[| 0] = context;
			ll[| 1] = name;
			ll[| 2] = key;
			ll[| 3] = modi;
			return ll;
		}
		
		static deserialize = function(ll) {
			var _k = is_string(ll[| 2])? ord(ll[| 2]) : ll[| 2];
			key  = _k;
			modi = ll[| 3];
		}
	}
	
	function addHotkey(_context, _name, _key, _mod, _action) {
		if(_key == "") _key = -1;
		if(is_string(_key)) _key = ord(_key);
		
		var key = new hotkeyObject(_context, _name, _key, _mod, _action);
		
		if(!ds_map_exists(HOTKEYS, _context)) {
			HOTKEYS[? _context] = ds_list_create();
			if(ds_list_find_index(HOTKEY_CONTEXT, _context) == -1)
				ds_list_add(HOTKEY_CONTEXT, _context);
		}
		
		for(var i = 0; i < ds_list_size(HOTKEYS[? _context]); i++) {
			var hotkey	= HOTKEYS[? _context][| i];
			if(hotkey.name == key.name) {
				delete HOTKEYS[? _context][| i];
				HOTKEYS[? _context][| i] = key;
				return;
			}
		}
		
		if(_context == "")
			ds_list_insert(HOTKEYS[? _context], 0, key);
		else
			ds_list_add(HOTKEYS[? _context], key);
	}
	
	function key_get_name(_key, _mod) {
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
			case vk_tab :         dk += "Tab"; break;
			case vk_home :        dk += "Home"; break;
			case vk_end :         dk += "End"; break;
			case vk_delete :      dk += "Delete"; break;
			case vk_insert :      dk += "Insert"; break; 
			case vk_pageup :      dk += "Page Up"; break;
			case vk_pagedown :    dk += "Page Down"; break;
			case vk_pause :       dk += "Pause"; break;
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
			default     : dk += ansi_char(_key);	break;	
		}
		
		return dk;
	}
#endregion

#region recent files
	globalvar RECENT_FILES;
	RECENT_FILES = ds_list_create();
	
	function RECENT_SAVE() {
		var map = ds_map_create();
		var l   = ds_list_create();
		ds_list_copy(l, RECENT_FILES);
		ds_map_add_list(map, "Recents", l);
		
		var path = DIRECTORY + "recent.json";
		var file = file_text_open_write(path);
		file_text_write_string(file, json_encode(map));
		file_text_close(file);
		ds_map_destroy(map);
	}
	
	function RECENT_LOAD() {
		var path = DIRECTORY + "recent.json";
		if(!file_exists(path)) return;
		
		var file = file_text_open_read(path);
		var load_str = "";
		while(!file_text_eof(file)) {
			load_str += file_text_readln(file);
		}
		file_text_close(file);
		var map = json_decode(load_str);
		
		if(ds_map_exists(map, "Recents")) {
			ds_list_copy(RECENT_FILES, map[? "Recents"]);	
			
			var del = ds_stack_create();
			for(var i = 0; i < ds_list_size(RECENT_FILES); i++)  {
				if(!file_exists(RECENT_FILES[| i])) ds_stack_push(del, i);
			}
			
			while(!ds_stack_empty(del)) {
				ds_list_delete(RECENT_FILES, ds_stack_pop(del));
			}
			
			ds_stack_destroy(del);
		}
	}
#endregion

#region save load
	function PREF_SAVE() {
		var map = ds_map_create();
		
		var save_l = ds_list_create();
		for(var j = 0; j < ds_list_size(HOTKEY_CONTEXT); j++) {
			var ll = HOTKEYS[? HOTKEY_CONTEXT[| j]];
			
			for(var i = 0; i < ds_list_size(ll); i++) {
				ds_list_add(save_l, ll[| i].serialize());
				ds_list_mark_as_list(save_l, ds_list_size(save_l) - 1);
			}
		}
		
		ds_map_add_list(map, "key", save_l);
		
		var _pref = ds_map_create();
		ds_map_override(_pref, PREF_MAP);
		ds_map_add_map(map, "preferences", _pref);
		
		var path = DIRECTORY + "keys.json";
		var file = file_text_open_write(path);
		file_text_write_string(file, json_encode(map));
		file_text_close(file);
		ds_map_destroy(map);
	}
	
	function PREF_LOAD() {
		var path = DIRECTORY + "keys.json";
		if(!file_exists(path)) return;
		
		var file = file_text_open_read(path);
		var load_str = "";
		while(!file_text_eof(file)) {
			load_str += file_text_readln(file);
		}
		file_text_close(file);
		var map = json_decode(load_str);	
		
		if(ds_map_exists(map, "key")) {
			var key = map[? "key"];
			for(var i = 0; i < ds_list_size(key); i++) {
				var key_list    = key[| i];
				var _context	= key_list[| 0];
				var name		= key_list[| 1];
				
				var _key = find_hotkey(_context, name);
				if(_key) 
					_key.deserialize(key_list);
			}
		}
		
		if(ds_map_exists(map, "preferences")) {
			ds_map_override(PREF_MAP, map[? "preferences"]);
		}
		
		ds_map_destroy(map);
		
		var ww, hh;
		
		if(PREF_MAP[? "window_maximize"]) {
			ww = window_get_width();
			hh = window_get_height();
		} else {
			ww = PREF_MAP[? "window_width"];
			hh = PREF_MAP[? "window_height"];
		}
		
		window_set_size(ww, hh);
		window_set_position(display_get_width() / 2 - ww / 2, display_get_height() / 2 - hh / 2);
	}
	
	function find_hotkey(_context, _name) {
		if(ds_map_exists(HOTKEYS, _context)) {
			for(var j = 0; j < ds_list_size(HOTKEYS[? _context]); j++) {
				if(HOTKEYS[? _context][| j].name == _name) {
					return HOTKEYS[? _context][| j];
				}
			}
		}
		return noone;
	}
#endregion