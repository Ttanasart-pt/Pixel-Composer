#region save
	globalvar LOADING, LOADING_VERSION, APPENDING, CLONING, SAFE_MODE;
	globalvar LOAD_ADDON;
	globalvar MODIFIED, CURRENT_PATH, READONLY, CONNECTION_CONFLICT, GLOBAL_SEED, ALWAYS_FULL;
	
	LOADING = false;
	LOAD_ADDON = {};
	CLONING = false;
	LOADING_VERSION = 0;
	APPENDING = false;
	READONLY  = false;
	SAFE_MODE = false;
	
	CURRENT_PATH = "";
	MODIFIED  = false;
	CONNECTION_CONFLICT = ds_queue_create();
	
	randomize();
	GLOBAL_SEED = irandom(9999999999);
	ALWAYS_FULL = false;
#endregion

#region main
	globalvar OS, DEBUG, THEME, COLOR_KEYS;
	OS = os_type;
	//OS = os_macosx;
	
	DEBUG = false;
	THEME = new Theme();
	COLOR_KEYS = [];
	
	globalvar VERSION, SAVEFILE_VERSION, VERSION_STRING, BUILD_NUMBER;
	
	VERSION = 1146;
	SAVEFILE_VERSION = 1440;
	VERSION_STRING   = "1.14.6";
	BUILD_NUMBER = 114600;
	
	globalvar NODES, NODE_MAP, APPEND_MAP, NODE_NAME_MAP;
	globalvar HOTKEYS, HOTKEY_CONTEXT, NODE_INSTANCES;
	
	NODES			= ds_list_create();
	NODE_INSTANCES	= ds_list_create();
	NODE_MAP	    = ds_map_create();
	NODE_NAME_MAP     = ds_map_create();
	APPEND_MAP      = ds_map_create();
	
	HOTKEYS			= ds_map_create();
	HOTKEY_CONTEXT	= ds_list_create();
	HOTKEY_CONTEXT[| 0] = "";
	
	globalvar CURSOR, TOOLTIP, DRAGGING, DIALOG_DEPTH_HOVER;
	globalvar UPDATE, RENDER_QUEUE;
#endregion

#region inputs
	globalvar FOCUS, FOCUS_STR, HOVER, HOVERING_ELEMENT, _HOVERING_ELEMENT;
	globalvar DOUBLE_CLICK;
	globalvar CURRENT_PATH, DIALOG_CLICK;
	
	CURRENT_PATH = "";
	DOUBLE_CLICK = false;
	FOCUS = noone;
	FOCUS_STR = "";
	HOVER = noone;
	HOVERING_ELEMENT  = noone;
	_HOVERING_ELEMENT = noone;
	DIALOG_CLICK = true;
	
	globalvar ADD_NODE_PAGE;
	ADD_NODE_PAGE = 0;
#endregion

#region macro
	#macro WIN_W window_get_width()
	#macro WIN_H window_get_height()
	
	#macro WIN_SW window_get_width()
	#macro WIN_SH window_get_height()
	
	#macro UI_SCALE PREF_MAP[? "display_scaling"]
	
	#macro mouse_mx device_mouse_x_to_gui(0)
	#macro mouse_my device_mouse_y_to_gui(0)
	#macro mouse_raw_x (device_mouse_raw_x(0) + window_get_x())
	#macro mouse_raw_y (device_mouse_raw_y(0) + window_get_y())
	#macro mouse_ui [device_mouse_x_to_gui(0), device_mouse_y_to_gui(0)]
	
	#macro sFOCUS FOCUS == self.id
	#macro sHOVER HOVER == self.id
	
	#macro DELTA_TIME delta_time / 1_000_000
	
	#macro CONF_TESTING false
	globalvar TESTING, TEST_ERROR;
	TESTING = CONF_TESTING;
	TEST_ERROR = false;
	
	#macro DEMO	false
	#macro ItchDemo:DEMO  true
	#macro SteamDemo:DEMO true
	#macro MacAlpha:DEMO  true
	
	#macro ALPHA false
	#macro MacAlpha:ALPHA true
	
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
	
	#macro RETURN_ON_REST if(!ANIMATOR.is_playing || !ANIMATOR.frame_progress) return;
	
	#macro PANEL_PAD THEME_VALUE.panel_padding
	
	function print(str) {
		//show_debug_message(string(str));
		noti_status(string(str));
	}
	
	function printIf(cond, log) {
		if(!cond) return;
		show_debug_message(log);
	}
#endregion

#region presets
	function INIT_FOLDERS() {
		if(!directory_exists(DIRECTORY + "Palettes"))
			directory_create(DIRECTORY + "Palettes");
		if(!directory_exists(DIRECTORY + "Gradients"))
			directory_create(DIRECTORY + "Gradients");
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

#region PATCH	
	#macro PATCH_STATIC static _doUpdate = function() { doUpdate() };
#endregion

#region debug
	global.FLAG = {};
#endregion