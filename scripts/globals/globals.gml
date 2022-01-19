#region save
	globalvar LOADING, APPENDING, READONLY, CONNECTION_CONFLICT, GLOBAL_SEED;
	LOADING   = false;
	APPENDING = false;
	READONLY  = false;
	CONNECTION_CONFLICT = ds_queue_create();
	
	randomize();
	GLOBAL_SEED = irandom(9999999999);
#endregion

#region main
	globalvar DEBUG;
	DEBUG = false;
	
	globalvar VERSION, SAVEFILE_VERSION, VERSION_STRING;
	VERSION = 82;
	SAVEFILE_VERSION = 82;
	VERSION_STRING = "0.8.2";
	
	globalvar NODES, ANIMATOR, NODE_MAP, APPEND_MAP, HOTKEYS, HOTKEY_CONTEXT;
	
	NODES		= ds_list_create();
	NODE_MAP	= ds_map_create();
	APPEND_MAP  = ds_map_create();
	
	HOTKEYS			= ds_map_create();
	HOTKEY_CONTEXT	= ds_list_create();
	HOTKEY_CONTEXT[| 0] = "";
	
	enum ANIMATOR_END {
		loop,
		stop
	}
	ANIMATOR = {
		frames_total : 30,
		current_frame : 0,
		real_frame : 0,
		framerate : 30,
		is_playing : false,
		is_scrubing : false,
		
		frame_progress : false,
		
		playback : ANIMATOR_END.loop
	};
#endregion

#region inputs
	globalvar FOCUS, FOCUS_STR, HOVER, DOUBLE_CLICK, CURRENT_PATH;
	globalvar TEXTBOX_ACTIVE;
	
	CURRENT_PATH = "";
	DOUBLE_CLICK = false;
	FOCUS = noone;
	FOCUS_STR = "";
	HOVER = noone;
	TEXTBOX_ACTIVE = noone
	
	globalvar ADD_NODE_PAGE, ADD_NODE_W, ADD_NODE_H;
	ADD_NODE_PAGE = "";
	ADD_NODE_W = 372 + 16 * 3 + 8;
	ADD_NODE_H = 320;
	
	globalvar AXIS_COLOR;
	AXIS_COLOR = [ c_ui_red, c_ui_lime, c_ui_cyan, c_yellow, c_aqua, c_fuchsia, c_orange, c_ltgray ];
#endregion

#region macro
	#macro WIN_W window_get_width() / PREF_MAP[? "display_scaling"]
	#macro WIN_H window_get_height() / PREF_MAP[? "display_scaling"]
	
	#macro mouse_mx device_mouse_x_to_gui(0)
	#macro mouse_my device_mouse_y_to_gui(0)
	
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
	#endregion
	
	#region functions
		#macro BLEND_ADD gpu_set_blendmode_ext(bm_one, bm_zero);
		#macro BLEND_NORMAL gpu_set_blendmode(bm_normal);
	#endregion
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
	globalvar DEF_SURFACE;
	function DEF_SURFACE_RESET() {
		DEF_SURFACE = surface_create(1, 1);
		surface_set_target(DEF_SURFACE);
			draw_clear_alpha(c_white, 0);
		surface_reset_target();
	}
	DEF_SURFACE_RESET();
#endregion