#region data
	globalvar PREF_MAP;
	PREF_MAP		= ds_map_create();
#endregion

#region pref map
	PREF_MAP[? "ui_framerate"] = 60;
	PREF_MAP[? "path_resolution"] = 32;
	
	PREF_MAP[? "double_click_delay"] = 0.25;
	PREF_MAP[? "mouse_wheel_speed"]  = 1.00;
	
	PREF_MAP[? "keyboard_repeat_start"] = 0.50;
	PREF_MAP[? "keyboard_repeat_speed"] = 0.10;
	
	PREF_MAP[? "show_splash"]			= true;
	PREF_MAP[? "splash_expand_recent"]  = false;
	PREF_MAP[? "notification_time"]		= 180;
	
	PREF_MAP[? "display_scaling"] = 1;
	
	PREF_MAP[? "window_width"]		= 1600;
	PREF_MAP[? "window_height"]		= 800;
	PREF_MAP[? "window_maximize"]	= false;
	
	PREF_MAP[? "connection_line_width"]	 = 2;
	PREF_MAP[? "connection_line_sample"] = 1;
	PREF_MAP[? "connection_line_corner"] = 8;
	PREF_MAP[? "connection_line_aa"]     = 2;
	PREF_MAP[? "connection_line_transition"] = true;
	PREF_MAP[? "connection_line_highlight"]  = 0;
	PREF_MAP[? "connection_line_highlight_fade"] = 0.75;
	PREF_MAP[? "connection_line_highlight_all"]  = false;
	PREF_MAP[? "curve_connection_line"]	 = 1;
	
	PREF_MAP[? "default_surface_side"]	= 32;
	
	PREF_MAP[? "panel_layout_file"] = "Vertical";
	PREF_MAP[? "panel_graph_dragging"]   = MOD_KEY.alt;
	PREF_MAP[? "panel_preview_dragging"] = MOD_KEY.alt;
	
	PREF_MAP[? "inspector_line_break_width"] = 500;
	
	PREF_MAP[? "node_show_render_status"] = false;
	PREF_MAP[? "node_show_time"] = true;
	
	PREF_MAP[? "collection_preview_speed"] = 60;
	PREF_MAP[? "expand_hover"] = false;
	
	PREF_MAP[? "graph_zoom_smoooth"] = 4;
	
	PREF_MAP[? "theme"] = "default";
	PREF_MAP[? "local"] = "en";
	
	PREF_MAP[? "dialog_add_node_grouping"] = true;
	PREF_MAP[? "dialog_add_node_view"] = 0;
	
	PREF_MAP[? "physics_gravity"] = [ 0, 10 ];
	
	PREF_MAP[? "test_mode"] = false;
	
	PREF_MAP[? "auto_save_time"] = 300;
	PREF_MAP[? "use_legacy_exception"] = false;
	
	PREF_MAP[? "dialog_add_node_w"] = 532;
	PREF_MAP[? "dialog_add_node_h"] = 400;
	
	PREF_MAP[? "panel_menu_resource_monitor"] = false;
	PREF_MAP[? "panel_menu_right_control"] = os_type == os_windows;
	
	PREF_MAP[? "show_crash_dialog"] = false;
	
	PREF_MAP[? "save_file_minify"] = true;
	
	PREF_MAP[? "render_all_export"] = true;
	
	PREF_MAP[? "alt_picker"] = true;
	PREF_MAP[? "clear_temp_on_close"] = true;
#endregion

#region recent files
	globalvar RECENT_FILES, RECENT_FILE_DATA;
	RECENT_FILES	 = ds_list_create();
	RECENT_FILE_DATA = ds_list_create();
	
	function RECENT_SAVE() {
		var map = ds_map_create();
		var l   = ds_list_create();
		ds_list_copy(l, RECENT_FILES);
		ds_map_add_list(map, "Recents", l);
		
		var path = DIRECTORY + "recent.json";
		var file = file_text_open_write(path);
		file_text_write_string(file, json_encode_minify(map));
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
			var l = map[? "Recents"];
			ds_list_clear(RECENT_FILES);
			
			for(var i = 0; i < ds_list_size(l); i++) {
				if(!file_exists(l[| i])) continue;
				ds_list_add(RECENT_FILES, l[| i]);
			}
		}
		
		RECENT_REFRESH();
	}
	
	function RECENT_REFRESH() {
		for( var i = 0; i < ds_list_size(RECENT_FILE_DATA); i++ ) {
			var d = RECENT_FILE_DATA[| i];
			if(sprite_exists(d.spr)) sprite_delete(d.spr);
			if(surface_exists(d.thumbnail)) surface_free(d.thumbnail);
		}
		
		ds_list_clear(RECENT_FILE_DATA);
		
		for( var i = 0; i < ds_list_size(RECENT_FILES); i++ ) {
			var p = RECENT_FILES[| i];
			RECENT_FILE_DATA[| i] = new FileObject(filename_name_only(p), p);
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
		
		PREF_MAP[? "window_maximize"]	= gameframe_is_maximized();
		PREF_MAP[? "window_width"]		= WIN_W;
		PREF_MAP[? "window_height"]		= WIN_H;
		
		var _pref = ds_map_create();
		ds_map_override(_pref, PREF_MAP);
		ds_map_arr_to_list(_pref);
		ds_map_add_map(map, "preferences", _pref);
		
		var path = DIRECTORY + "keys.json";
		file_text_write_all(path, json_encode_minify(map));
		ds_map_destroy(map);
		
		json_save_struct(DIRECTORY + "Nodes/fav.json",	  global.FAV_NODES);
		json_save_struct(DIRECTORY + "Nodes/recent.json", global.RECENT_NODES);
		
		json_save_struct(DIRECTORY + "key_nodes.json", HOTKEYS_CUSTOM);
	}
	
	function PREF_LOAD() {
		var path = DIRECTORY + "keys.json";
		if(!file_exists(path)) return;
		
		var load_str = file_text_read_all(path);
		var map = json_decode(load_str);	
		
		if(ds_map_exists(map, "key")) {
			var key = map[? "key"];
			for(var i = 0; i < ds_list_size(key); i++) {
				var key_list    = key[| i];
				var _context	= key_list[| 0];
				var name		= key_list[| 1];
				
				var _key = find_hotkey(_context, name);
				if(_key) _key.deserialize(key_list);
			}
		}
		
		if(ds_map_exists(map, "preferences")) {
			ds_map_list_to_arr(map[? "preferences"]);
			ds_map_override(PREF_MAP, map[? "preferences"]);
		}
		
		ds_map_destroy(map);
		
		if(!directory_exists(DIRECTORY + "Themes/" + PREF_MAP[? "theme"]))
			PREF_MAP[? "theme"] = "default";
			
		var f = json_load_struct(DIRECTORY + "key_nodes.json");
		struct_override(HOTKEYS_CUSTOM, f);
		
		LOCALE_USE_DEFAULT = PREF_MAP[? "local"] == "en";
	}
	
	function PREF_APPLY() {
		if(PREF_MAP[? "double_click_delay"] > 1)
			PREF_MAP[? "double_click_delay"] /= 60;
		
		if(ds_map_exists(PREF_MAP, "test_mode"))
			TESTING = PREF_MAP[? "test_mode"];
		
		if(ds_map_exists(PREF_MAP, "use_legacy_exception")) {
			if(PREF_MAP[? "use_legacy_exception"])
				resetException();
			else 
				setException();
		}
		
		if(OS != os_macosx && !LOADING) {
			if(PREF_MAP[? "window_maximize"]) {
				gameframe_maximize();
			} else {
				var ww = PREF_MAP[? "window_width"];
				var hh = PREF_MAP[? "window_height"];
			
				window_set_position(display_get_width() / 2 - ww / 2, display_get_height() / 2 - hh / 2);
				window_set_size(ww, hh);
			}
		}
		game_set_speed(PREF_MAP[? "ui_framerate"], gamespeed_fps);
		
		if(ds_map_exists(PREF_MAP, "physics_gravity")) {
			var grav = PREF_MAP[? "physics_gravity"];
			if(!is_array(grav)) {
				grav = [0, 10];
				PREF_MAP[? "physics_gravity"] = grav;
			}
			physics_world_gravity(array_safe_get(grav, 0, 0), array_safe_get(grav, 1, 10));
		}
	}
	
	function find_hotkey(_context, _name) {
		if(!ds_map_exists(HOTKEYS, _context)) return noone;
		
		for(var j = 0; j < ds_list_size(HOTKEYS[? _context]); j++) {
			if(HOTKEYS[? _context][| j].name == _name)
				return HOTKEYS[? _context][| j];
		}
	}
#endregion