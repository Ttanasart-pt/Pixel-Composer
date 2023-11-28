#region preference
	globalvar PREFERENCES, PREFERENCES_DEF, HOTKEYS_DATA;
	PREFERENCES  = {};
	HOTKEYS_DATA = {};
	
	PREFERENCES.ui_framerate					= 120;
	PREFERENCES.path_resolution					= 32;
	
	PREFERENCES.node_recents_amount				= 20;
												
	PREFERENCES.double_click_delay				= 0.25;
	PREFERENCES.mouse_wheel_speed				= 1.00;
												
	PREFERENCES.keyboard_repeat_start			= 0.50;
	PREFERENCES.keyboard_repeat_speed			= 0.10;
												
	PREFERENCES.show_splash						= true;
	PREFERENCES.splash_expand_recent			= false;
	PREFERENCES.notification_time				= 180;
												
	PREFERENCES.display_scaling					= 1;
	PREFERENCES.window_width					= 1600;
	PREFERENCES.window_height					= 800;
	PREFERENCES.window_maximize					= false;
	
	PREFERENCES.connection_line_width			= 2;
	PREFERENCES.connection_line_sample			= 1;
	PREFERENCES.connection_line_corner			= 8;
	PREFERENCES.connection_line_aa				= 2;
	PREFERENCES.connection_line_transition		= true;
	PREFERENCES.connection_line_highlight		= 0;
	PREFERENCES.connection_line_highlight_fade	= 0.75;
	PREFERENCES.connection_line_highlight_all	= false;
	PREFERENCES.curve_connection_line			= 1;
	
	PREFERENCES.default_surface_side			= 32;
	
	PREFERENCES.panel_layout_file				= "Vertical";
	PREFERENCES.panel_graph_dragging			= MOD_KEY.alt;
	PREFERENCES.panel_preview_dragging			= MOD_KEY.alt;
	
	PREFERENCES.inspector_focus_on_double_click	= true;
	PREFERENCES.inspector_view_default			= 1;
	
	PREFERENCES.node_show_render_status			= false;
	PREFERENCES.node_show_time					= true;
	
	PREFERENCES.collection_preview_speed		= 60;
	PREFERENCES.expand_hover					= false;
	
	PREFERENCES.graph_zoom_smoooth				= 4;
	PREFERENCES.graph_open_group_in_tab			= false;
	
	PREFERENCES.theme							= "default";
	PREFERENCES.local							= "en";
	PREFERENCES.font_overwrite					= "";
	
	PREFERENCES.dialog_add_node_grouping		= true;
	PREFERENCES.dialog_add_node_view			= 0;
	
	PREFERENCES.physics_gravity					= [ 0, 10 ];
												
	PREFERENCES.test_mode						= false;
	PREFERENCES.auto_save_time					= 300;
	PREFERENCES.use_legacy_exception			= false;
	
	PREFERENCES.dialog_add_node_w				= 532;
	PREFERENCES.dialog_add_node_h				= 400;
	
	PREFERENCES.panel_menu_resource_monitor		= false;
	PREFERENCES.panel_menu_right_control		= os_type == os_windows;
	
	PREFERENCES.show_crash_dialog				= false;
	PREFERENCES.save_file_minify				= true;
	PREFERENCES.render_all_export				= true;
	
	PREFERENCES.alt_picker						= true;
	PREFERENCES.clear_temp_on_close				= true;
	PREFERENCES.pan_mouse_key					= mb_middle;
	
	PREFERENCES.widget_autocomplete_delay       = 500;
	
	PREFERENCES.show_supporter_icon				= true;
	
	PREFERENCES.temp_path						= "%DIR%/temp/";
	PREFERENCES.ImageMagick_path				= "%APP%/ImageMagick/";
	PREFERENCES.webp_path						= "%APP%/webp/";
	PREFERENCES.gifski_path						= "%APP%/gifski/";
	PREFERENCES.ffmpeg_path						= "%APP%/ffmpeg/";
	
	PREFERENCES_DEF = variable_clone(PREFERENCES);
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
		var map = {};
		
		var save_l = [];
		for(var j = 0; j < ds_list_size(HOTKEY_CONTEXT); j++) {
			var ll = HOTKEYS[? HOTKEY_CONTEXT[| j]];
			
			for(var i = 0; i < ds_list_size(ll); i++)
				array_push(save_l, ll[| i].serialize());
		}
		
		map.key = save_l;
		
		PREFERENCES.window_maximize	= window_is_maximized;
		PREFERENCES.window_width	= max(960, window_minimize_size[0]);
		PREFERENCES.window_height	= max(600, window_minimize_size[1]);
		
		map.preferences = PREFERENCES;
		
		json_save_struct(DIRECTORY + "keys.json",         map);
		json_save_struct(DIRECTORY + "Nodes/fav.json",	  global.FAV_NODES);
		json_save_struct(DIRECTORY + "Nodes/recent.json", global.RECENT_NODES);
		json_save_struct(DIRECTORY + "key_nodes.json",    HOTKEYS_CUSTOM);
	}
	
	function PREF_LOAD() {
		var path = DIRECTORY + "keys.json";
		if(!file_exists(path)) return;
		
		var map = json_load_struct(path);	
		HOTKEYS_DATA = {};
		
		for(var i = 0; i < array_length(map.key); i++) {
			var key_list    = map.key[i];
			var _context	= is_struct(key_list)? key_list.context : key_list[0];
			var name		= is_struct(key_list)? key_list.name    : key_list[1];
			
			HOTKEYS_DATA[$ $"{_context}_{name}"] = key_list;
		}
		
		struct_override(PREFERENCES, map.preferences);
		
		if(!directory_exists($"{DIRECTORY}Themes/{PREFERENCES.theme}"))
			PREFERENCES.theme = "default";
			
		var f = json_load_struct(DIRECTORY + "key_nodes.json");
		struct_override(HOTKEYS_CUSTOM, f);
		
		LOCALE_DEF = PREFERENCES.local == "en";
		
		directory_verify(filepath_resolve(PREFERENCES.temp_path));
	}
	
	function PREF_APPLY() {
		if(PREFERENCES.double_click_delay > 1)
			PREFERENCES.double_click_delay /= 60;
		
		TESTING = struct_try_get(PREFERENCES, "test_mode", false);
		
		if(PREFERENCES.use_legacy_exception) resetException();
		else                                 setException();
		
		if(OS != os_macosx && !LOADING) {
			if(PREFERENCES.window_maximize) {
				winMan_Maximize();
			} else {
				var ww = PREFERENCES.window_width;
				var hh = PREFERENCES.window_height;
				window_minimize_size = [ ww, hh ];
				
				window_set_position(display_get_width() / 2 - ww / 2, display_get_height() / 2 - hh / 2);
				window_set_size(ww, hh);
			}
		}
		
		window_refresh();
		game_set_speed(PREFERENCES.ui_framerate, gamespeed_fps);
		
		var grav = struct_try_get(PREFERENCES, "physics_gravity", [ 0, 10 ]);
		physics_world_gravity(array_safe_get(grav, 0, 0), array_safe_get(grav, 1, 10));
	}
	
	function find_hotkey(_context, _name) {
		if(!ds_map_exists(HOTKEYS, _context)) return noone;
		
		for(var j = 0; j < ds_list_size(HOTKEYS[? _context]); j++) {
			if(HOTKEYS[? _context][| j].name == _name)
				return HOTKEYS[? _context][| j];
		}
	}
#endregion