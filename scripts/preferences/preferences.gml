#region preference
	globalvar PREFERENCES, PREFERENCES_DEF, PREFERENCES_DIR;
	PREFERENCES  = {};
	HOTKEYS_DATA = {};
	
	#region GENERAL UI
												
		PREFERENCES.display_scaling					= 1;
		PREFERENCES.window_width					= 1600;
		PREFERENCES.window_height					= 800;
		PREFERENCES.window_maximize					= false;
		PREFERENCES.window_monitor					= "";
		PREFERENCES.window_fix					    = false;
		PREFERENCES.window_fix_width				= 1600;
		PREFERENCES.window_fix_height				= 800;
		PREFERENCES.window_shadow                   = true;
		
		PREFERENCES.theme							= "default";
		PREFERENCES.theme_override					= "override";
		PREFERENCES.local							= "en";
		PREFERENCES.font_overwrite					= "";
		
		PREFERENCES.ui_framerate					= 120;
		PREFERENCES.ui_framerate_non_focus			= 10;
		PREFERENCES.path_resolution					= 32;
		PREFERENCES.move_directory					= false;
		
		PREFERENCES.notification_time				= 180;
		PREFERENCES.notify_load_version				= true;
		PREFERENCES.show_crash_dialog				= false;
		
		PREFERENCES.test_mode						= false;
		PREFERENCES.auto_save_time					= 300;
		PREFERENCES.use_legacy_exception			= false;
	
		PREFERENCES.caret_blink						= 0.75;
	
		PREFERENCES.textbox_shake					= 0;
		PREFERENCES.textbox_particle				= 0;
	
	#endregion
			
	#region IO
				
		PREFERENCES.double_click_delay				= 0.25;
		PREFERENCES.mouse_wheel_speed				= 1.00;
		
		PREFERENCES.pen_pool_delay					= 1;
		PREFERENCES.slider_lock_mouse				= true;
		
		PREFERENCES.keyboard_repeat_start			= 0.50;
		PREFERENCES.keyboard_repeat_speed			= 0.10;
		PREFERENCES.keyboard_double_delay			= 0.25;
		PREFERENCES.keyboard_check_sweep			= true;
		PREFERENCES.keyboard_capture_raw			= true;
		
		PREFERENCES.file_watcher_delay              = 0.1;
		
	#endregion
	
	#region DIALOG
		
		PREFERENCES.node_recents_amount				= 20;
			
		PREFERENCES.show_splash						= true;
		PREFERENCES.splash_expand_recent			= false;
	
		PREFERENCES.dialog_add_node_grouping		= true;
		PREFERENCES.dialog_add_node_view			= 0;
	
		PREFERENCES.dialog_add_node_w				= 532;
		PREFERENCES.dialog_add_node_h				= 400;
		PREFERENCES.dialog_add_node_search_high		= true;
		
		PREFERENCES.add_node_remember				= true;
		
		PREFERENCES.file_explorer_view				= FILE_EXPLORER_VIEW.list;
	
	#endregion
	
	#region PANEL
	
		PREFERENCES.panel_layout_file				= "Vertical";
	
		PREFERENCES.panel_graph_dragging			= MOD_KEY.alt;
		PREFERENCES.panel_graph_group_require_shift	= true;
	
		PREFERENCES.panel_preview_dragging			= MOD_KEY.alt;
		PREFERENCES.panel_preview_show_real_fps		= false;
		// PREFERENCES.panel_preview_tran_colors		= [  ];
	
		PREFERENCES.panel_menu_resource_monitor		= false;
		PREFERENCES.panel_menu_right_control		= os_type == os_windows;
	
		PREFERENCES.panel_menu_palette_node_size    = 20;
	
		PREFERENCES.inspector_focus_on_double_click	= true;
		PREFERENCES.inspector_view_default			= INSP_VIEW_MODE.compact;
	
		PREFERENCES.node_show_render_status			= false;
		PREFERENCES.node_show_time					= true;
		
		PREFERENCES.expand_hover					= false;
	
		PREFERENCES.graph_zoom_smoooth				= 4;
		PREFERENCES.graph_open_group_in_tab			= false;
		
		PREFERENCES.collection_animated				= true;
		PREFERENCES.collection_label				= true;
		PREFERENCES.collection_preview_speed		= 60;
		PREFERENCES.collection_scale				= 1;
		
		PREFERENCES.palette_stretch				    = false;
		
		PREFERENCES.pan_mouse_key					= mb_middle;
		PREFERENCES.panel_outline_accent			= true;
	#endregion
	
	#region WIDGET
	
		PREFERENCES.widget_autocomplete_delay       = 500;
		PREFERENCES.alt_picker						= true;
	
	#endregion
	
	#region NODES
		
		PREFERENCES.node_add_select			        = true;
		
		PREFERENCES.node_param_show					= false;
		PREFERENCES.node_param_width				= 192;
		PREFERENCES.node_3d_preview_size			= 256;
		
		PREFERENCES.node_default_depth				= 3;
		PREFERENCES.node_default_oversample			= 1;
		PREFERENCES.node_default_interpolation		= 1;
	
	#endregion
	
	#region SAVE
	
		PREFERENCES.save_file_minify				= true;
		PREFERENCES.save_backup						= 1;
		PREFERENCES.save_thumbnail					= false;
		PREFERENCES.save_layout						= false;
		PREFERENCES.save_compress                   = true;
	
	#endregion
	
	#region MISC
		
		PREFERENCES.render_all_export				= true;
		PREFERENCES.clear_temp_on_close				= true;
	
		PREFERENCES.show_supporter_icon				= true;
		PREFERENCES.welcome_file_order				= [ "Getting started", "Sample Projects" ];
		PREFERENCES.welcome_file_closed				= [];
	
	#endregion
	
	#region PATHS
	
		PREFERENCES.temp_path			= "%DIR%/temp/";
		PREFERENCES.ImageMagick_path	= "%APP%/ImageMagick/";
		PREFERENCES.webp_path			= "%APP%/webp/";
		PREFERENCES.gifski_path			= "%APP%/gifski/";
		PREFERENCES.ffmpeg_path			= "%APP%/ffmpeg/";
		
		PREFERENCES.file_explorer       = "";
		PREFERENCES.dialog_path         = "";
		
		PREFERENCES.path_assets         = [];
		PREFERENCES.path_fonts          = [];
		PREFERENCES.path_welcome        = [];
		
		PREFERENCES.versions			= {};
	
	#endregion
	
	#region PROJECT
		PREFERENCES.project_animation_duration  = 30;
		PREFERENCES.project_animation_framerate = 30;
		
		PREFERENCES.project_previewGrid = {
			show	: false,
			snap	: false,
			size	: [ 16, 16 ],
			opacity : 0.5,
			color   : cola(#6d6d81),
			pixel   : false,
		}
		
		PREFERENCES.project_previewSetting = {
			show_info             : true,
			show_view_control     : 1,
			
			d3_tool_snap          : false,
            d3_tool_snap_position : 1,
            d3_tool_snap_rotation : 15,
		}
		
		PREFERENCES.project_graphGrid = {
			show	    : true,
			show_origin : false,
			snap	    : true,
			size	    : 16,
			color       : cola(c_white),
			opacity     : 0.05,
			highlight   : 12,
		}
		
		PREFERENCES.project_graphDisplay = {
			show_grid	    : true,
			show_dimension  : true,
			show_compute    : true,
			show_view_control : 1,
			
			avoid_label     : false,
			preview_scale   : 100,
			highlight       : false,
			
			show_control    : false,
			show_tooltip    : true,
		}
		
		PREFERENCES.project_graphConnection = {
			type : 1, 
			
			line_width			: 2,
			line_sample			: 1,
			line_corner			: 8,
			line_aa				: 2,
			line_highlight		: 0,
			line_highlight_fade	: 0.75,
			line_highlight_all	: false,
			line_extend			: 16,
		}
		
	#endregion
	
	PREFERENCES_DEF = variable_clone(PREFERENCES);
#endregion

#region project attributes
	globalvar PROJECT_ATTRIBUTES;
	
	PROJECT_ATTRIBUTES = {}
	
	PROJECT_ATTRIBUTES.strict            = false;
	PROJECT_ATTRIBUTES.surface_dimension = [ 32, 32 ];
	PROJECT_ATTRIBUTES.palette           = [ cola(c_white), cola(c_black) ];
	PROJECT_ATTRIBUTES.palette_fix       = false;
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
		if(!file_exists_empty(path)) return;
		
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
				if(!file_exists_empty(l[| i])) continue;
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
			RECENT_FILE_DATA[| i] = new FileObject(p);
		}
	}
#endregion

#region save load
	globalvar PREF_VERSION, PREF_UPDATES;
	PREF_UPDATES = [
		{
			version: 0,
			exists: function() /*=>*/  {return file_exists(DIRECTORY + "keys.json")},
			update: function() /*=>*/ {
				var _pth_k = DIRECTORY + "keys.json";
				var _pth_h = DIRECTORY + "hotkeys.json";
				var _pth_d = DIRECTORY + "default_project.json";
				
				if(file_exists(_pth_k)) file_copy(_pth_k, PREFERENCES_DIR + "keys.json");
				if(file_exists(_pth_h)) file_copy(_pth_h, PREFERENCES_DIR + "hotkeys.json");
				if(file_exists(_pth_d)) file_copy(_pth_d, PREFERENCES_DIR + "default_project.json");
			}
		},
	];
	
	function PREF_UPDATE() {
		directory_verify(PREFERENCES_DIR);
		var _oldest = -1;
		
		for (var i = 0, n = array_length(PREF_UPDATES); i < n; i++) {
			var _pf = PREF_UPDATES[i];
			if(_pf.exists()) {
				_oldest = i;
				break;
			}
		}
		
		if(_oldest == -1) return;
		for(var i = _oldest; i >= 0; i--) {
			var _pf = PREF_UPDATES[i];
			_pf.update();
		}
	}
	
	function PREF_SAVE() {
		if(IS_CMD) return;
		
		directory_verify($"{DIRECTORY}Preferences");
		directory_verify($"{DIRECTORY}Preferences/{PREF_VERSION}");
		
		PREFERENCES.window_maximize	= window_is_maximized;
		PREFERENCES.window_width	= max(960, window_minimize_size[0]);
		PREFERENCES.window_height	= max(600, window_minimize_size[1]);
		PREFERENCES.window_monitor  = window_monitor;
		
		json_save_struct(PREFERENCES_DIR + "keys.json",             PREFERENCES);
		json_save_struct(PREFERENCES_DIR + "default_project.json",  PROJECT_ATTRIBUTES);
		json_save_struct(DIRECTORY + "Nodes/fav.json",              variable_struct_get_names(global.FAV_NODES));
		json_save_struct(DIRECTORY + "Nodes/recent.json",           global.RECENT_NODES);
		
		hotkey_serialize();
	}
	
	function PREF_LOAD() {
		directory_verify($"{DIRECTORY}Preferences");
		if(!directory_exists(PREFERENCES_DIR)) PREF_UPDATE();
		
		var path = PREFERENCES_DIR + "keys.json";
		if(file_exists(path)) {
			should_restart = true;
			var _map = json_load_struct(path);
			
			if(struct_has(_map, "preferences")) 
				struct_override(PREFERENCES, _map.preferences, true);
			else 
				struct_override(PREFERENCES, _map, true);
		}
		
		if(!directory_exists($"{DIRECTORY}Themes/{PREFERENCES.theme}"))
			PREFERENCES.theme = "default";
		
		LOCALE_DEF = PREFERENCES.local == "en";
		THEME_DEF  = PREFERENCES.theme == "default";
		FONT_DEF   = PREFERENCES.theme == "default" && PREFERENCES.local == "en" && PREFERENCES.display_scaling == 1 && PREFERENCES.font_overwrite == "";
		
		directory_verify(filepath_resolve(PREFERENCES.temp_path));
		
		if(PREFERENCES.move_directory) directory_set_current_working(DIRECTORY);
		
		var f = json_load_struct(PREFERENCES_DIR + "default_project.json");
		struct_override(PROJECT_ATTRIBUTES, f);
		
		hotkey_deserialize();
		
		TESTING = struct_try_get(PREFERENCES, "test_mode", false);
	}
	
	function PREF_APPLY() {
		
		if(PREFERENCES.double_click_delay > 1)
			PREFERENCES.double_click_delay /= 60;
		
		TESTING = struct_try_get(PREFERENCES, "test_mode", false);
		if(TESTING && GM_build_type == "run") {
			log_message("PREFERENCE", "Dev mode enabled");
			instance_create_depth(0, 0, 0, addon_key_displayer);
		}
		
		_=PREFERENCES.use_legacy_exception? resetException() : setException();
		
		var ww = PREFERENCES.window_fix? PREFERENCES.window_fix_width  : PREFERENCES.window_width;
		var hh = PREFERENCES.window_fix? PREFERENCES.window_fix_height : PREFERENCES.window_height;
		window_minimize_size = [ ww, hh ];
		
		var cx = display_get_width()  / 2;
		var cy = display_get_height() / 2;
		
		if(OS == os_windows) {
			var _monitors = display_measure_all();
			
			if(is_array(_monitors))
			for( var i = 0, n = array_length(_monitors); i < n; i++ ) {
				var _m = _monitors[i];
				if(!is_array(_m) || array_length(_m) < 10) continue;
				
				if(PREFERENCES.window_monitor == _m[9]) {
					cx = _m[0] + _m[2] / 2;
					cy = _m[1] + _m[3] / 2;
				}
			}
		}
		
		window_set_rectangle(cx - ww / 2, cy - hh / 2, ww, hh);
		if(PREFERENCES.window_maximize) winMan_Maximize();
		window_refresh();
	}
#endregion

#region get set
	function getPreference(_k, _pref = PREFERENCES) {
		var _sep = string_splice(_k, ".");
		var _pnt = PREFERENCES;
		
		for( var i = 0, n = array_length(_sep); i < n; i++ ) {
			var _s = _sep[i];
			if(!struct_has(_pnt, _s)) return noone;
			_pnt = _pnt[$ _s];
		}
		
		return _pnt;
	}
	
	function setPreference(_k, _v) {
		var _sep = string_splice(_k, ".");
		var _pnt = PREFERENCES;
		
		for( var i = 0, n = array_length(_sep); i < n; i++ ) {
			var _s = _sep[i];
			if(!struct_has(_pnt, _s)) return noone;
			
			if(i == n - 1) _pnt[$ _s] = _v;
			else _pnt = _pnt[$ _s];
		}
		
		PREF_SAVE();
	}
#endregion

#region command palette
	//!#mfunc __regFnPref {"args":["name"," key"],"order":[0,1]}
#macro __regFnPref_mf0  { registerFunctionLite("Preference", 
#macro __regFnPref_mf1 , function() { dialogPanelCall(new Panel_Preference().goto(
#macro __regFnPref_mf2 )); }); }
	
	function __fnInit_Preference() {
		__regFnPref_mf0 __txtx("pref_double_click_delay",              "Double click delay") __regFnPref_mf1       		     "double_click_delay"               __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_mouse_wheel_speed",               "Scroll speed") __regFnPref_mf1             		     "mouse_wheel_speed"                __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_keyboard_hold_start",             "Keyboard hold start") __regFnPref_mf1      		     "keyboard_repeat_start"            __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_keyboard_repeat_delay",           "Keyboard repeat delay") __regFnPref_mf1    		     "keyboard_repeat_speed"            __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_expand_hovering_panel",           "Expand hovering panel") __regFnPref_mf1    		     "expand_hover"                     __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_expand_lock_mouse_slider",        "Lock mouse when sliding") __regFnPref_mf1  		     "slider_lock_mouse"                __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_pen_pool_delay",                  "Pen leave delay") __regFnPref_mf1          		     "pen_pool_delay"                   __regFnPref_mf2
		
		__regFnPref_mf0 __txtx("pref_auto_save_time",   		       "Autosave delay (-1 to disable)") __regFnPref_mf1     "auto_save_time"                   __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_save_layout",      		       "Save layout") __regFnPref_mf1                        "save_layout"                      __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_save_file_minify", 		       "Minify save file") __regFnPref_mf1                   "save_file_minify"                 __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_save_backups",     		       "Backup saves") __regFnPref_mf1                       "save_backup"                      __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_legacy_exception", 		       "Use legacy exception handler") __regFnPref_mf1       "use_legacy_exception"             __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_crash_dialog",     		       "Show dialog after crash") __regFnPref_mf1            "show_crash_dialog"                __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_clear_temp",       		       "Clear temp file on close") __regFnPref_mf1           "clear_temp_on_close"              __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_enable_test_mode", 		       "Enable developer mode*") __regFnPref_mf1             "test_mode"                        __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_exp_popup_dialog", 		       "Pop-up Dialog") __regFnPref_mf1                      "multi_window"                     __regFnPref_mf2
		
		__regFnPref_mf0 __txtx("pref_gui_scaling",                     "GUI scaling") __regFnPref_mf1 						 "ui_scale"						    __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_ui_frame_rate",                   "UI frame rate") __regFnPref_mf1                      "ui_framerate"                     __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_ui_frame_rate",                   "UI inactive frame rate") __regFnPref_mf1             "ui_framerate_non_focus"           __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_interface_language",              "Interface Language*") __regFnPref_mf1                "local"                            __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_ui_font",                         "Overwrite UI font") + "*" __regFnPref_mf1            "font_overwrite"                   __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_windows_control",                 "Use Windows style window control.") __regFnPref_mf1  "panel_menu_right_control"         __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_ui_fix_window_size",              "Fix Window size on start") __regFnPref_mf1           "window_fix"                       __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_ui_fix_width",                    "Fix width") __regFnPref_mf1                          "window_fix_width"                 __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_ui_fix_height",                   "Fix height") __regFnPref_mf1                         "window_fix_height"                __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_supporter_icon",                  "Show supporter icon") __regFnPref_mf1                "show_supporter_icon"              __regFnPref_mf2
		
		__regFnPref_mf0 __txtx("pref_add_node_remember",               "Remember add node position") __regFnPref_mf1         "add_node_remember"                __regFnPref_mf2
		
		__regFnPref_mf0 __txtx("pref_graph_group_in_tab",              "Open group in new tab") __regFnPref_mf1              "graph_open_group_in_tab"          __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_graph_zoom_smoothing",            "Graph zoom smoothing") __regFnPref_mf1               "graph_zoom_smoooth"               __regFnPref_mf2
		__regFnPref_mf0 __txtx("panel_graph_group_require_shift",      "Hold Shift to enter group") __regFnPref_mf1          "panel_graph_group_require_shift"  __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_use_alt",                         "Use ALT for") __regFnPref_mf1                        "alt_picker"                       __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_preview_show_real_fps",           "Show real fps") __regFnPref_mf1                      "panel_preview_show_real_fps"      __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_inspector_focus_on_double_click", "Focus on double click") __regFnPref_mf1              "inspector_focus_on_double_click"  __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_collection_preview_speed",        "Collection preview speed") __regFnPref_mf1           "collection_preview_speed"         __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_warning_notification_time",       "Warning notification time") __regFnPref_mf1          "notification_time"                __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_widget_autocomplete_delay",       "Code Autocomplete delay") __regFnPref_mf1            "widget_autocomplete_delay"        __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_widget_textbox_shake",            "Textbox shake") __regFnPref_mf1                      "textbox_shake"                    __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_widget_textbox_particles",        "Textbox particles") __regFnPref_mf1                  "textbox_particle"                 __regFnPref_mf2
		
		__regFnPref_mf0 __txtx("pref_node_param_show",                 "Show paramater on new node") __regFnPref_mf1         "node_param_show"                  __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_node_param_width",                "Default param width") __regFnPref_mf1                "node_param_width"                 __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_node_3d_preview",                 "Preview surface size") __regFnPref_mf1               "node_3d_preview_size"             __regFnPref_mf2
		__regFnPref_mf0 __txtx("pref_file_watcher_delay",              "File watcher delay (s)") __regFnPref_mf1             "file_watcher_delay"               __regFnPref_mf2
	}
#endregion

