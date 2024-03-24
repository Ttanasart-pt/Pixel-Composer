#region save
	globalvar LOADING, APPENDING, CLONING;
	globalvar CONNECTION_CONFLICT;
	globalvar MESSAGE;
	
	LOADING		= false;
	CLONING		= false;
	APPENDING	= false;
	MESSAGE     = noone;
	
	CONNECTION_CONFLICT = ds_queue_create();
	
	randomize();
#endregion

#region ======================================================================= MAIN =======================================================================
	globalvar OS, DEBUG, THEME, COLOR_KEYS;
	globalvar CMD, CMDIN;
	
	OS    = os_type;
	CMD   = [];
	CMDIN = [];
	
	DEBUG = false;
	THEME = new Theme();
	COLOR_KEYS = [];
	
	globalvar VERSION, SAVE_VERSION, VERSION_STRING, BUILD_NUMBER, LATEST_VERSION;

	LATEST_VERSION	= 11600;
	VERSION			= 11680;
	SAVE_VERSION	= 11680;
	VERSION_STRING  = "1.16.8";
	BUILD_NUMBER	= 11680;
	
	globalvar APPEND_MAP;
	APPEND_MAP      = ds_map_create();
	
	globalvar HOTKEYS, HOTKEY_CONTEXT;
	HOTKEYS			= ds_map_create();
	HOTKEY_CONTEXT	= ds_list_create();
	HOTKEY_CONTEXT[| 0] = "";
	
	globalvar CURSOR, CURSOR_LOCK, CURSOR_LOCK_X, CURSOR_LOCK_Y;
	globalvar TOOLTIP, DRAGGING, DIALOG_DEPTH_HOVER;
#endregion

#region inputs
	globalvar FOCUS, FOCUS_STR, HOVER, HOVERING_ELEMENT, _HOVERING_ELEMENT;
	globalvar DOUBLE_CLICK, DOUBLE_CLICK_POS;
	globalvar DIALOG_CLICK;
	
	DOUBLE_CLICK_POS = [ 0, 0 ];
	DOUBLE_CLICK = false;
	
	FOCUS     = noone;
	FOCUS_STR = "";
	
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
	
	#macro sFOCUS FOCUS == self.id
	#macro sHOVER HOVER == self.id
	
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
	function __fnInit_Global() {
		__registerFunction("fullscreen",	global_fullscreen);
		__registerFunction("render_all",	global_render_all);
		__registerFunction("project_close",	global_project_close);
		
		__registerFunction("theme_reload",	global_theme_reload);
	}
	
	function global_fullscreen()	{ CALL("fullscreen");		winMan_setFullscreen(!window_is_fullscreen);	}
	function global_render_all()	{ CALL("render_all");		RENDER_ALL_REORDER								}
	function global_project_close()	{ CALL("project_close");	PANEL_GRAPH.close();							}
	
	function global_theme_reload()	{ CALL("theme_reload");		loadGraphic(PREFERENCES.theme); resetPanel();	}
#endregion

#region debug
	global.FLAG = {};
#endregion