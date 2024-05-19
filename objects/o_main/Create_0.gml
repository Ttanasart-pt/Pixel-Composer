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

#region window
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
	CURSOR_LOCK		   = false;
	CURSOR_IS_LOCK	   = false;
	CURSOR_LOCK_X	   = 0;
	CURSOR_LOCK_Y	   = 0;
	TOOLTIP            = "";
	DRAGGING           = noone;
	KEYBOARD_STRING    = "";
	
	RENDER_QUEUE = new Queue();
	RENDER_ORDER = [];
	
	globalvar AUTO_SAVE_TIMER;
	AUTO_SAVE_TIMER = 0;
	
	_cursor	 = CURSOR;
	dc_check = 0;
	kb_time  = 0;
	kb_hold  = false;
	kb_hkey  = 0;
	
	fpss = array_create(10);
	fpsr = 0;
	
	_cursor_lock = false;
	
	watcher_surface = surface_create(1, 1);
	
	panelInit();
	
	addHotkey("", "New file", "N",				MOD_KEY.ctrl, NEW);
	if(!DEMO) {
		addHotkey("", "Save", "S",				MOD_KEY.ctrl,					SAVE);
		addHotkey("", "Save as", "S",			MOD_KEY.ctrl | MOD_KEY.shift,	SAVE_AS);
		addHotkey("", "Save all", "S",			MOD_KEY.ctrl | MOD_KEY.alt,		SAVE_ALL);
		addHotkey("", "Open", "O",				MOD_KEY.ctrl,					LOAD);
	}
	
	addHotkey("", "Undo", "Z",					MOD_KEY.ctrl,					UNDO);
	addHotkey("", "Redo", "Z",					MOD_KEY.ctrl | MOD_KEY.shift,	REDO);
	
	addHotkey("", "Full panel",   "`",			MOD_KEY.none,					set_focus_fullscreen);
	addHotkey("", "Reset layout", vk_f10,		MOD_KEY.ctrl,					resetPanel);
	
	addHotkey("", "Open notification", vk_f12,	MOD_KEY.none,					function() { dialogPanelCall(new Panel_Notification()); });
	
	addHotkey("", "Fullscreen", vk_f11,			MOD_KEY.none,					global_fullscreen);
	addHotkey("", "Render all", vk_f5,			MOD_KEY.none,					global_render_all);
	
	addHotkey("", "Close file", "Q",			MOD_KEY.ctrl,					global_project_close);
	addHotkey("", "Close program", vk_f4,		MOD_KEY.alt,					window_close);
	addHotkey("", "Reload theme", vk_f10,		MOD_KEY.ctrl | MOD_KEY.shift,	global_theme_reload);
	
	globalvar HOTKEY_MOD, HOTKEY_BLOCK;
	HOTKEY_MOD   = 0;
	HOTKEY_BLOCK = false;
	
#endregion

#region Loader
	globalvar GIF_READER;
	
	GIF_READER = ds_list_create();
	gif_complete_st = ds_stack_create();
#endregion

#region tunnel
	globalvar TUNNELS_IN, TUNNELS_IN_MAP, TUNNELS_OUT;
	TUNNELS_IN     = ds_map_create();
	TUNNELS_IN_MAP = ds_map_create();
	TUNNELS_OUT    = ds_map_create();
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
	
	drop_path = [];
	
	function load_file_path(path, _x = undefined, _y = undefined) {
		if(!is_array(path)) path = [ path ];
		if(array_length(path) == 0) return; 
		
		_x = _x == undefined? (PANEL_GRAPH.w / 2) / PANEL_GRAPH.graph_s - PANEL_GRAPH.graph_x : _x;
		_y = _y == undefined? (PANEL_GRAPH.h / 2) / PANEL_GRAPH.graph_s - PANEL_GRAPH.graph_y : _y;
		
		var type = "others";
		
		if(array_length(path) == 1 && directory_exists(path[0]))
			type = "image";
			
		for( var i = 0, n = array_length(path); i < n; i++ ) {
			var p = path[i];
			var ext = string_lower(filename_ext(p));
			
			switch(ext) {
				case ".png"	 :
				case ".jpg"	 :
				case ".jpeg" :
					type = "image";
					break;
			}
		}
		
		var is_multi = type == "image" && (array_length(path) > 1 || directory_exists(path[0]));
		
		if(is_multi) {
			with(dialogCall(o_dialog_add_multiple_images, WIN_W / 2, WIN_H / 2))
				setPath(path);
		} else {
			if(!IS_CMD) PANEL_GRAPH.onStepBegin();
			
			var node = noone;
			for( var i = 0, n = array_length(path); i < n; i++ ) {
				var p = path[i];
				var ext = string_lower(filename_ext(p));
				
				switch(ext) {
					case ".txt"  :
						node = Node_create_Text_File_Read_path(_x, _y, p);
						break;
						
					case ".csv"  :
						node = Node_create_CSV_File_Read_path(_x, _y, p);
						break;
						
					case ".json"  :
						node = Node_create_Json_File_Read_path(_x, _y, p);
						break;
						
					case ".ase"  :
					case ".aseprite"  :
						node = Node_create_ASE_File_Read_path(_x, _y, p);
						break;
						
					case ".png"	 :
					case ".jpg"	 :
					case ".jpeg" :
						if(key_mod_press(SHIFT))
							node = Node_create_Image_path(_x, _y, p);
						else 
							node = Node_create_Image_path(_x, _y, p);
						break;
						
					case ".gif" :
						node = Node_create_Image_gif_path(_x, _y, p);
						break;
						
					case ".obj" :
						node = Node_create_3D_Obj_path(_x, _y, p);
						break;
						
					case ".wav" :
						node = Node_create_WAV_File_Read_path(_x, _y, p);
						break;
						
					case ".pxc" :
					case ".cpxc" :
						LOAD_PATH(p);
						break;
						
					case ".pxcc" :
						APPEND(p);
						break;
				}
				
				if(!IS_CMD)PANEL_GRAPH.mouse_grid_y += 160;
			}
			
			if(node && !IS_CMD)
				PANEL_GRAPH.toCenterNode();
		}
	}
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
	
	instance_create(0, 0, o_dialog_textbox_autocomplete);
	instance_create(0, 0, o_dialog_textbox_function_guide);
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
#endregion

#region steam
	globalvar STEAM_ENABLED, STEAM_APP_ID, STEAM_USER_ID, STEAM_USERNAME;
	globalvar STEAM_UGC_ITEM_UPLOADING, STEAM_UGC_ITEM_ID, STEAM_UGC_ITEM_FILE, STEAM_UGC_UPDATE_HANDLE;
	globalvar STEAM_UGC_SUBMIT_ID, STEAM_UGC_UPDATE_MAP, STEAM_UGC_PUBLISH_ID, STEAM_UGC_UPDATE, STEAM_UGC_TYPE;
	globalvar STEAM_SUB_ID;
	
	enum STEAM_UGC_FILE_TYPE {
		collection,
		project,
		node_preset
	}
	
	STEAM_UGC_TYPE = STEAM_UGC_FILE_TYPE.collection;
	STEAM_SUB_ID   = 0;
	STEAM_USER_ID  = 0;
	STEAM_USERNAME = "";
	
	STEAM_UGC_UPDATE_HANDLE = 0;
	STEAM_UGC_ITEM_ID = 0;
	STEAM_UGC_PUBLISH_ID = 0;
	STEAM_UGC_SUBMIT_ID = 0;
	STEAM_UGC_ITEM_UPLOADING = false;
	STEAM_ENABLED = steam_initialised();
	STEAM_UGC_UPDATE = false;
	STEAM_UGC_UPDATE_MAP = ds_map_create();
	
	if(STEAM_ENABLED) {
		STEAM_APP_ID = steam_get_app_id();
		STEAM_USER_ID = steam_get_user_account_id();
		STEAM_USERNAME = steam_get_persona_name();
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
	globalvar USE_DEPTH;
	_use_depth = noone;
	USE_DEPTH  = false;
	
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

#region arguments
	#macro IS_CMD PROGRAM_ARGUMENTS._cmd
	
	alarm[1] = 2;
	
	globalvar PROGRAM_ARGUMENTS, CLI_EXPORT_AMOUNT;
	
	PROGRAM_ARGUMENTS = { 
		_path :      "",
		_cmd :       false,
		_run :       false,
		_rendering : false,
		_exporting : [],
		_persist :   false,
		_trusted:    false,
		_lua:        true,
	};
	
	CLI_EXPORT_AMOUNT = 0;
	
	var paramCount = parameter_count();
	var paramType  = "_path";
	var useTCP     = false;
	
	for( var i = 0; i < paramCount; i++ ) {
		var param = parameter_string(i);
		//print($"    >>> params {i}: {param}");
		
		if(string_starts_with(param, "-")) {
			switch(param) {
				case "-c" : 
				case "--crashed" : 
					if(PREFERENCES.show_crash_dialog) 
						run_in(1, function() { dialogCall(o_dialog_crashed); });
					break;
				
				case "-h" : 
				case "--headless" : 
					PROGRAM_ARGUMENTS._cmd = true; 
					break;
					
				case "-p" : 
				case "--persist" : 
					PROGRAM_ARGUMENTS._persist = true; 
					break;
					
				case "-t" : 
				case "--trusted" : 
					PROGRAM_ARGUMENTS._trusted = true; 
					break;
					
				case "-s" : 
				case "--server" : 
					PROGRAM_ARGUMENTS._persist = true; 
					useTCP = true;
					break;
					
				case "-sl" : 
				case "--skiplua" : 
					PROGRAM_ARGUMENTS._lua = false; 
					break;
					
				default :
					paramType = string_trim(param, ["-"]);
					break;
			}
			
		} else if(paramType == "_path") {
			var path = param;
			    path = string_replace_all(path, "\n", "");
			    path = string_replace_all(path, "\"", "");
				
			if(file_exists_empty(path) && (filename_ext(path) == ".pxc" || filename_ext(path) == ".cpxc"))
				PROGRAM_ARGUMENTS._path = path;
				
		} else
			PROGRAM_ARGUMENTS[$ paramType] = cmd_path(param);
	}
	
	if(IS_CMD) {
		draw_enable_drawevent(false);
		log_console($"Running PixelComposer {VERSION_STRING}");
		
		PROGRAM_ARGUMENTS._run = true; 
		PROGRAM_ARGUMENTS._rendering = true; 
	}
	
	if(file_exists_empty(PROGRAM_ARGUMENTS._path)) {
		run_in(1, function() { load_file_path(PROGRAM_ARGUMENTS._path); });
		
	} else if(IS_CMD)
		game_end();
	
	if(useTCP && struct_has(PROGRAM_ARGUMENTS, "port")) {
		TCP_PORT   = PROGRAM_ARGUMENTS.port;
		TCP_SERVER = network_create_server_raw(network_socket_tcp, TCP_PORT, 32);
		
		log_console($"Open port: {TCP_PORT}");
	}
#endregion