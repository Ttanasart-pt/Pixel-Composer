gml_release_mode(true);
gml_pragma("UnityBuild", "true");

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

#region // MAIN
	globalvar OS, DEBUG, RUN_IDE;
	globalvar CMD, CMDIN, CMDPRG;
	globalvar FPS_REAL;
	
	#macro MAC (OS == os_macosx)
	
	OS       = os_type;
	CMD      = [];
	CMDIN    = [];
	CMDPRG   = noone;
	
	// display_set_timing_method(tm_systemtiming);
	window_set_showborder(OS != os_windows);
	
	FPS_REAL = 0;
	RUN_IDE  = GM_build_type == "run";
	DEBUG    = false;
	COLOR_KEY_ARRAY = [];
	
	globalvar VERSION, SAVE_VERSION, VERSION_STRING, BUILD_NUMBER, LATEST_VERSION, NIGHTLY, RELEASE_STRING;
	
	LATEST_VERSION	= 1_19_00_0;
	VERSION			= 1_19_08_0;
	SAVE_VERSION	= 1_19_06_0;
	VERSION_STRING  = MAC? "1.18.003m" : "1.19.8.003";
	RELEASE_STRING  = "1.19.8";
	BUILD_NUMBER	= 1_19_08_0.003;
	PREF_VERSION    = 1_17_1;
	
	var _lsp = array_last(string_split(VERSION_STRING, "."));
	NIGHTLY  = string_length(_lsp) == 3;
	
	globalvar HOTKEYS, HOTKEY_CONTEXT;
	HOTKEYS        = {};
	HOTKEY_CONTEXT = [0];
	
	globalvar TOOLTIP, DRAGGING, DIALOG_DEPTH_HOVER;
	global.DOWNLOAD_LINKS = "";
	
	globalvar CURRENT_COLOR; CURRENT_COLOR = ca_white;
#endregion

#region input
	globalvar FOCUS, FOCUS_STR, FOCUS_CONTENT, FOCUS_STACK, HOVER, HOVERING_ELEMENT, _HOVERING_ELEMENT;
	globalvar DOUBLE_CLICK;
	globalvar DIALOG_CLICK;
	globalvar TOOLTIP_WINDOW;
	
	FOCUS	          = noone;
	FOCUS_CONTENT     = noone;
	FOCUS_STR	      = "";
	FOCUS_STACK       = ds_stack_create();
	
	DOUBLE_CLICK      = false;
	
	HOVER             = noone;
	HOVERING_ELEMENT  = noone;
	_HOVERING_ELEMENT = noone;
	
	DIALOG_CLICK      = true;
	
	globalvar ADD_NODE_PAGE, ADD_NODE_SCROLL, ADD_NODE_SUBPAGE;
	
	ADD_NODE_PAGE    = 0;
	ADD_NODE_SUBPAGE = 0;
	ADD_NODE_SCROLL  = 0;
	TOOLTIP_WINDOW   = noone;
#endregion

#region macro
	#macro TEMPDIR filepath_resolve(PREFERENCES.temp_path)
	
	#macro NOT_LOAD !LOADING && !APPENDING
	
	#macro WIN_X window_get_x()
	#macro WIN_Y window_get_y()
	#macro WIN_W window_get_width()
	#macro WIN_H window_get_height()
	
	#macro WIN_SW window_get_width()
	#macro WIN_SH window_get_height()
	
	#macro UI_SCALE PREFERENCES.display_scaling
	
	#macro mouse_ui [mouse_mx, mouse_my]
	#macro mouse_mx (PEN_USE? PEN_X : device_mouse_raw_x(0))
	#macro mouse_my (PEN_USE? PEN_Y : device_mouse_raw_y(0))
	
	#macro mouse_mxs (FILE_IS_DROPPING? FILE_DROPPING_X : mouse_mx)
	#macro mouse_mys (FILE_IS_DROPPING? FILE_DROPPING_Y : mouse_my)
	
	#macro mouse_raw_x display_mouse_get_x()
	#macro mouse_raw_y display_mouse_get_y()
	
	#macro sFOCUS (FOCUS == self.id)
	#macro sHOVER (!CURSOR_IS_LOCK && (HOVER == self.id))
	#macro DIALOG_SHOW_FOCUS (FOCUS == self.id || (instance_exists(o_dialog_menubox) && o_dialog_menubox.getContextPanel() == self))
	
	#macro DELTA_TIME delta_time / 1_000_000
	
	#macro INLINE gml_pragma("forceinline");
	#macro is __is_instanceof
	function  __is_instanceof(a,b) { return is_struct(a) && is_instanceof(a,b) };
	
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
		
		#macro ca_white cola(c_white)
		#macro ca_black cola(c_black)
		#macro ca_zero  cola(c_black, 0)
	#endregion
	
	#macro RETURN_ON_REST if(!PROJECT.animator.is_playing || !PROJECT.animator.frame_progress) return;
	#macro PANEL_PAD THEME_VALUE.panel_padding
	
	#macro INIT_BASE_CLASS base = static_get(static_get(self));
	
	//!#mfunc returnNull {"args":["v"," a"],"order":[0,1,0,0]}
#macro returnNull_mf0  var 
#macro returnNull_mf1  = 
#macro returnNull_mf2 ; if(is_undefined(
#macro returnNull_mf3 ) || 
#macro returnNull_mf4  == noone) return;
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

#region debug
	global.FLAG = {
		render				: 0,
		renderTime			: false,
		keyframe_override	: true,
		wav_import			: true,
		ase_import			: false,
	};
#endregion