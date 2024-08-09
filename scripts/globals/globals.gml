#region save
	globalvar LOADING, CLONING, CLONING_GROUP;
	globalvar CONNECTION_CONFLICT, LOADING_VERSION;
	globalvar MESSAGE;
	
	globalvar APPENDING, APPEND_MAP, APPEND_LIST;
	APPEND_MAP      = ds_map_create();
	APPEND_LIST     = [];
	
	LOADING		    = false;
	LOADING_VERSION = 0;
	CLONING_GROUP   = noone;
	CLONING		    = false;
	APPENDING	    = false;
	MESSAGE         = noone;
	
	CONNECTION_CONFLICT = ds_queue_create();
	
	randomize();
#endregion

#region ======================================================================= MAIN =======================================================================
	globalvar OS, DEBUG, THEME, COLOR_KEYS;
	globalvar CMD, CMDIN;
	globalvar FPS_REAL;
	
	OS       = os_type;
	CMD      = [];
	CMDIN    = [];
	FPS_REAL = 0;
	
	DEBUG = false;
	THEME = new Theme();
	COLOR_KEYS = [];
	
	globalvar VERSION, SAVE_VERSION, VERSION_STRING, BUILD_NUMBER, LATEST_VERSION;
	globalvar HOTKEYS, HOTKEY_CONTEXT;

	LATEST_VERSION	= 11700;
	VERSION			= 11790;
	SAVE_VERSION	= 11700;
	VERSION_STRING  = "1.17.10.003";
	BUILD_NUMBER	= 11790;
	
	HOTKEYS			= ds_map_create();
	HOTKEY_CONTEXT	= ds_list_create();
	HOTKEY_CONTEXT[| 0] = "";
	
	globalvar TOOLTIP, DRAGGING, DIALOG_DEPTH_HOVER;
	global.KEYS = { download_links: "" };
	
	globalvar CURRENT_COLOR;
	CURRENT_COLOR = c_white;
#endregion

#region input
	globalvar FOCUS, FOCUS_STR, FOCUS_CONTENT, HOVER, HOVERING_ELEMENT, _HOVERING_ELEMENT;
	globalvar DOUBLE_CLICK, DOUBLE_CLICK_POS;
	globalvar DIALOG_CLICK;
	
	DOUBLE_CLICK_POS = [ 0, 0 ];
	DOUBLE_CLICK = false;
	
	FOCUS	      = noone;
	FOCUS_CONTENT = noone;
	FOCUS_STR	  = "";
	
	HOVER             = noone;
	HOVERING_ELEMENT  = noone;
	_HOVERING_ELEMENT = noone;
	
	DIALOG_CLICK = true;
	
	globalvar ADD_NODE_PAGE, ADD_NODE_SCROLL;
	
	ADD_NODE_PAGE   = 0;
	ADD_NODE_SCROLL = 0;
#endregion

#region macro
	#macro TEMPDIR filepath_resolve(PREFERENCES.temp_path)
	
	#macro NOT_LOAD !LOADING && !APPENDING
	
	#macro WIN_W window_get_width()
	#macro WIN_H window_get_height()
	
	#macro WIN_SW window_get_width()
	#macro WIN_SH window_get_height()
	
	#macro UI_SCALE PREFERENCES.display_scaling
	
	#macro mouse_mx (PEN_USE? PEN_X : device_mouse_x_to_gui(0))
	#macro mouse_my (PEN_USE? PEN_Y : device_mouse_y_to_gui(0))
	#macro mouse_raw_x (device_mouse_raw_x(0) + window_get_x())
	#macro mouse_raw_y (device_mouse_raw_y(0) + window_get_y())
	#macro mouse_ui [device_mouse_x_to_gui(0), device_mouse_y_to_gui(0)]
	
	#macro sFOCUS (FOCUS == self.id)
	#macro sHOVER (!CURSOR_IS_LOCK && HOVER == self.id)
	
	#macro DELTA_TIME delta_time / 1_000_000
	
	#macro INLINE gml_pragma("forceinline");
	
	#macro CONF_TESTING false
	globalvar TESTING, TEST_ERROR;
	TESTING = CONF_TESTING;
	TEST_ERROR = false;
	
	#macro DEMO	false
	#macro ItchDemo:DEMO  true
	#macro SteamDemo:DEMO true
	
	#region color
		#macro c_ui_blue_dkblack	$251919
		#macro c_ui_blue_mdblack	$2c1e1e
		#macro c_ui_blue_black		$362727
		#macro c_ui_blue_dkgrey		$4e3b3b
		#macro c_ui_blue_grey		$816d6d
		#macro c_ui_blue_ltgrey		$8f7e7e
		#macro c_ui_blue_white		$e8d6d6
		#macro c_ui_cyan			$e9ff88
		
		#macro c_ui_yellow			$78e4ff
		#macro c_ui_orange			$6691ff
		#macro c_ui_orange_light	$92c2ff
		
		#macro c_ui_red				$4b00eb
		#macro c_ui_pink			$b700eb
		#macro c_ui_purple			$d40092
		
		#macro c_ui_lime_dark		$38995e
		#macro c_ui_lime			$5dde8f
		#macro c_ui_lime_light		$b2ffd0
		
		#macro c_ui_white			$ffffff
	#endregion
	
	#macro printlog if(log) show_debug_message
	
	#macro RETURN_ON_REST if(!PROJECT.animator.is_playing || !PROJECT.animator.frame_progress) return;
	
	#macro PANEL_PAD THEME_VALUE.panel_padding
	
	function print(str) {
		INLINE
		noti_status(string(str));
	}
	
	function printIf(cond, log) {
		INLINE
		if(cond) print(log);
	}
	
#endregion

#region presets
	function INIT_FOLDERS() {
		directory_verify(DIRECTORY + "Palettes");
		directory_verify(DIRECTORY + "Gradients");
	}
#endregion

#region default
	globalvar DEF_SURFACE, USE_DEF;
	DEF_SURFACE = noone;
	USE_DEF = -10;
	
	function DEF_SURFACE_RESET() {
		if(is_surface(DEF_SURFACE)) return;
		
		DEF_SURFACE = surface_create_valid(32, 32);
		surface_set_target(DEF_SURFACE);
			draw_clear(c_white);
		surface_reset_target();
	}
	DEF_SURFACE_RESET();
#endregion

#region functions
	function global_fullscreen()		{ CALL("fullscreen");			winMan_setFullscreen(!window_is_fullscreen);										}
	function global_project_close()		{ CALL("close_project");		PANEL_GRAPH.close();																}
	function global_project_close_all()	{ CALL("close_project_all");	 for( var i = array_length(PROJECTS) - 1; i >= 0; i-- ) closeProject(PROJECTS[i]);	}
	function global_theme_reload()		{ CALL("reload_theme");			loadGraphic(PREFERENCES.theme); resetPanel();										}
	
	function global_render_all()		{ CALL("render_all");			RENDER_ALL_REORDER																	}
	function global_export_all()		{ 
		for (var i = 0, n = array_length(PROJECT.allNodes); i < n; i++) {
			var node = PROJECT.allNodes[i];
			
			if(!node.active) continue;
			if(instanceof(node) != "Node_Export") continue;
			
			node.doInspectorAction();
		}
	}
	
	function __fnInit_Global() {
		registerFunction("", "New file",			"N",	MOD_KEY.ctrl,					NEW);
		
		if(!DEMO) {
			registerFunction("", "Save",			"S",	MOD_KEY.ctrl,					SAVE);
			registerFunction("", "Save as", 		"S",	MOD_KEY.ctrl | MOD_KEY.shift,	SAVE_AS);
			registerFunction("", "Save at", 		"",		MOD_KEY.none,					SAVE_AT, [ ARG("project", function() { return PROJECT; }, true), ARG("path", ""), ARG("log", "save at ") ]);
			registerFunction("", "Save all",		"S",	MOD_KEY.ctrl | MOD_KEY.alt,		SAVE_ALL);
			registerFunction("", "Open",			"O",	MOD_KEY.ctrl,					LOAD);
			registerFunction("", "Open Safe",		"",		MOD_KEY.none,					LOAD_SAFE);
			registerFunction("", "Open at",			"",		MOD_KEY.none,					LOAD_AT, [ ARG("path", ""), ARG("readonly", false), ARG("override", false) ]);
			registerFunction("", "Append",			"",		MOD_KEY.none,					APPEND,  [ ARG("path", ""), ARG("context", function() { return PANEL_GRAPH.getCurrentContext(); }, true) ]);
			
			registerFunction("", "Import .zip",		"",		MOD_KEY.none,					__IMPORT_ZIP);
			registerFunction("", "Export .zip",		"",		MOD_KEY.none,					__EXPORT_ZIP);
		}
		
		registerFunction("", "Undo",				"Z",	MOD_KEY.ctrl,					UNDO);
		registerFunction("", "Redo",				"Z",	MOD_KEY.ctrl | MOD_KEY.shift,	REDO);
		
		registerFunction("", "Full panel",  		"`",	MOD_KEY.none,					set_focus_fullscreen);
		registerFunction("", "Reset layout",		vk_f10, MOD_KEY.ctrl,					resetPanel);
		
		registerFunction("", "Open notification",	vk_f12, MOD_KEY.none,					function() /*=>*/ { dialogPanelCall(new Panel_Notification()); });
		
		registerFunction("", "Fullscreen",			vk_f11, MOD_KEY.none,					global_fullscreen);
		registerFunction("", "Render all",			vk_f5,	MOD_KEY.none,					global_render_all);
		registerFunction("", "Export all",			"",		MOD_KEY.none,					global_export_all);
		
		registerFunction("", "Close file",			"Q",	MOD_KEY.ctrl,					global_project_close);
		registerFunction("", "Close all files",		"",		MOD_KEY.none,					global_project_close_all);
		registerFunction("", "Close program",		vk_f4,	MOD_KEY.alt,					window_close);
		registerFunction("", "Close project",		"",		MOD_KEY.none,					closeProject, [ ARG("project", function() { return PROJECT; }, true) ]);
		registerFunction("", "Reload theme",		vk_f10, MOD_KEY.ctrl | MOD_KEY.shift,	global_theme_reload);
	}
	
#endregion

#region debug
	global.FLAG = {
		render				: 0,
		renderTime			: false,
		keyframe_override	: true,
		wav_import			: true,
		ase_import			: false,
	};
#endregion