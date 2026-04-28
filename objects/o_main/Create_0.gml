/// @description init
#region log
	var path = "log_temp.txt";
	var file = file_text_open_append(path);
	file_text_write_string(file, $"[MESSAGE] {_log_template()}session begin\n");
	file_text_close(file);
	
	gpu_set_tex_mip_enable(mip_off);
	gc_enable(true);
	gc_target_frame_time(100);
#endregion

#region arguments
	#macro IS_CMD PROGRAM_ARGUMENTS._cmd
	globalvar PROGRAM_ARGUMENTS, CLI_EXPORT_AMOUNT;
	
	alarm[1] = 2;
	
	PROGRAM_ARGUMENTS = { 
		_path:       "",
		_cmd:        false,
		
		_persist:    false,
		_trusted:    false,
		_lua:        false,
		_nodir:      false, 
		
		_rendering:  0,
		_exporting:  [],
		
	};
	
	CLI_EXPORT_AMOUNT = 0;
	
	var paramCount = parameter_count();
	var paramType  = "_path";
	var useTCP     = false;
	
	for( var i = 0; i < paramCount; i++ ) {
		var param = parameter_string(i);
		show_debug_message($"    >>> params {i}: {param}");
		
		if(string_starts_with(param, "-")) {
			switch(param) {
				case "-h"  : case "--headless": PROGRAM_ARGUMENTS._cmd     = true; draw_enable_drawevent(false); break;
				case "-p"  : case "--persist" : PROGRAM_ARGUMENTS._persist = true;                break;
				case "-t"  : case "--trusted" : PROGRAM_ARGUMENTS._trusted = true;                break;
				case "-s"  : case "--server"  : PROGRAM_ARGUMENTS._persist = true; useTCP = true; break;
				case "-l"  : case "--lua"     : PROGRAM_ARGUMENTS._lua     = true;                break;
				case "-nd" : case "--nodir"   : PROGRAM_ARGUMENTS._nodir   = true;                break;
				default : paramType = string_trim(param, ["-"]); break;
			}
			
		} else if(paramType == "_path") {
			var path = param;
			    path = string_replace_all(path, "\n", "");
			    path = string_replace_all(path, "\"", "");
				
			if(path_is_project(path))
				PROGRAM_ARGUMENTS._path = path;
				
		} else
			PROGRAM_ARGUMENTS[$ paramType] = cmd_path(param);
	}
	
	// TEST
	// PROGRAM_ARGUMENTS._path = "D:/Project/MakhamDev/LTS-PixelComposer/EXE/1.21.0/project/clibw.pxc";
	// PROGRAM_ARGUMENTS._cmd  = true;
	// PROGRAM_ARGUMENTS.in    = "D:/Project/MakhamDev/LTS-PixelComposer/EXE/1.21.0/thumbnail.png";
	// PROGRAM_ARGUMENTS.out   = "D:/Project/MakhamDev/LTS-PixelComposer/EXE/1.21.0/thumbnailBW.png";
	// var p = "D:/Project/MakhamDev/LTS-PixelComposer/EXE/1.21.0/*.png"; print(p, cmd_path(p));
	
	if(IS_CMD) {
		draw_enable_drawevent(false);
		log_console($"Running PixelComposer {VERSION_STRING}");
		PROGRAM_ARGUMENTS._rendering = 1; 
	}
	
	if(file_exists_empty(PROGRAM_ARGUMENTS._path)) {
		run_in(1, function() /*=>*/ {return load_file_path(PROGRAM_ARGUMENTS._path)});
		
	} else if(IS_CMD) {
		show_debug_message("Cmd mode with empty path. exiting...")
		game_end();
	}
	
	if(useTCP && struct_has(PROGRAM_ARGUMENTS, "port")) {
		TCP_PORT   = PROGRAM_ARGUMENTS.port;
		TCP_SERVER = network_create_server_raw(network_socket_tcp, TCP_PORT, 32);
		
		log_console($"Open port: {TCP_PORT}");
	}
#endregion

#region window & IO
	window_set_min_width(960);
	window_set_min_height(600);
	draw_set_circle_precision(64);
	winManInit();
	
	depth       = 0;
	win_wp      = WIN_W;
	win_hp      = WIN_H;
	win_resize  = false;
	
	room_width  = WIN_W;
	room_height = WIN_H;
	
	DIALOG_DEPTH_HOVER = 0;
	UPDATE             = RENDER_TYPE.none;
	CURSOR             = cr_default;
	CURSOR_SPRITE      = noone;
	CURSOR_LOCK		   = false;
	CURSOR_IS_LOCK	   = false;
	CURSOR_LOCK_X	   = 0;
	CURSOR_LOCK_Y	   = 0;
	TOOLTIP            = "";
	DRAGGING           = noone;
	KEYBOARD_RESET
	
	globalvar AUTO_SAVE_TIMER;
	AUTO_SAVE_TIMER = 0;
	
	key_mod_init();
	
	_cursor	 = CURSOR;
	dc_check = 0;
	dclick   = [0,0];
	
	fpss = array_create(10);
	fpsr = 0;
	
	_cursor_lock    = false;
	watcher_surface = surface_create(1, 1);
	windows_focused = true;
	
	panelInit();
	
#endregion

#region Loader
	globalvar GIF_READER;
	
	GIF_READER = ds_list_create();
	gif_complete_st = ds_stack_create();
#endregion

#region add on callback
	globalvar ANIMATION_PRE, ANIMATION_POST;
	
	ANIMATION_PRE = [];
	ANIMATION_POST = [];
	
	function __addon_preAnim() {
		for( var i = 0, n = array_length(ANIMATION_PRE); i < n; i++ ) 
			ANIMATION_PRE[i]();
	}
	
	function __addon_postAnim() {
		for( var i = 0, n = array_length(ANIMATION_POST); i < n; i++ ) 
			ANIMATION_POST[i]();
	}
#endregion

#region file drop
	if(OS == os_windows) {
		file_dropper_init();
		
	} else if(OS == os_macosx) {
		file_dnd_set_hwnd(window_handle());
		file_dnd_set_enabled(true);
		
		_file_dnd_filelist  = "";
		file_dnd_filelist   = "";
		file_dnd_pattern    = "*.*";
		file_dnd_allowfiles = true; 
		file_dnd_allowdirs  = true;
		file_dnd_allowmulti = true;
	}
	
	globalvar FILE_IS_DROPPING, FILE_DROPPING_X, FILE_DROPPING_Y, FILE_DROPPING, FILE_DROPPED;
	
	FILE_IS_DROPPING = false;
	FILE_DROPPING_X  = 0;
	FILE_DROPPING_Y  = 0;
	FILE_DROPPING    = [];
	FILE_DROPPED     = false;
	_FILE_DROPPED    = false;
#endregion

#region undo
	action_last_frame = [];
#endregion

#region version
	version_check = -1;
	version_latest = 0;
	
	//if(os_is_network_connected()) {
	//	var version = "https://gist.githubusercontent.com/Ttanasart-pt/d9eefbda84a78863c122b8b155bc0cda/raw/version.txt";
	//	version_check = http_get(version);
	//}
#endregion

#region parameter
	minimized = false;
	_modified = false;
#endregion

#region dialog
	globalvar DIALOGS, WIDGET_TAB_BLOCK;
	DIALOGS = ds_list_create();
	WIDGET_TAB_BLOCK = false;
	
	if(!IS_CMD) run_in(1, function() /*=>*/ {
		instance_create(0, 0, o_dialog_textbox_autocomplete);
		instance_create(0, 0, o_dialog_textbox_function_guide);
	});
#endregion

#region async
	globalvar PORT_MAP, NETWORK_SERVERS, NETWORK_CLIENTS;
	globalvar IMAGE_FETCH_MAP;
	
	global.FILE_LOAD_ASYNC = ds_map_create();
	PORT_MAP = ds_map_create();
	NETWORK_SERVERS = ds_map_create();
	NETWORK_CLIENTS = ds_map_create();
	
	IMAGE_FETCH_MAP = ds_map_create();
	
	asyncInit();
	
	network_set_config(network_config_use_non_blocking_socket, 0);
	if(!os_is_network_connected()) array_push(NETWORK_LOG, new notification(NOTI_TYPE.internal, $"Network offline"));
#endregion

#region steam
	globalvar STEAM_ENABLED;         STEAM_ENABLED         = steam_initialised();
	globalvar STEAM_APP_ID;          STEAM_APP_ID          = 0;
	globalvar STEAM_ID;              STEAM_ID              = 0;
	globalvar STEAM_USER_ID;         STEAM_USER_ID         = 0;
	globalvar STEAM_USERNAME;        STEAM_USERNAME        = "";
	globalvar STEAM_AVATAR;          STEAM_AVATAR          = 0;
	globalvar STEAM_UGC_ITEM_AVATAR; STEAM_UGC_ITEM_AVATAR = true;
	globalvar STEAM_UGC_UPLOADING;   STEAM_UGC_UPLOADING   = false;
	
	steam_avatar_id = "";
	
	if(STEAM_ENABLED) {
		STEAM_APP_ID    = steam_get_app_id();
		STEAM_USER_ID   = steam_get_user_account_id();
		STEAM_ID        = steam_get_user_steam_id();
		STEAM_USERNAME  = steam_get_persona_name();
		steam_avatar_id = steam_get_user_avatar(STEAM_ID, steam_user_avatar_size_large);
		
		steam_set_warning_message_hook();
	}
#endregion

#region physics
	physics_world_update_iterations(100);
#endregion

#region color selector
	globalvar NODE_DROPPER_TARGET, NODE_DROPPER_TARGET_CAN, NODE_COLOR_SHOW_PALETTE;
	NODE_DROPPER_TARGET		= noone;
	NODE_DROPPER_TARGET_CAN = false;
	NODE_COLOR_SHOW_PALETTE = false;
#endregion

#region draw
	
#endregion

#region 3D
	globalvar USE_DEPTH; USE_DEPTH = false;
	_use_depth = noone;
	
	set3DGlobalPreview();
#endregion

#region debug
	global.__debug_runner = 0;
	__debug_animator_counter = 0;
	
	//instance_create(0, 0, o_video_banner, { title: "Trail effect" });
	//instance_create_depth(0, 0, -32000, FLIP_Domain);
	//instance_create_depth(0, 0, -32000, FLIP_Domain);
#endregion

#region server
	globalvar TCP_SERVER, TCP_PORT, TCP_CLIENTS;
	TCP_SERVER  = false;
	TCP_PORT    = noone;
	TCP_CLIENTS = [];
	
#endregion