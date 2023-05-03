/// @description init
#region log
	var path = "log_temp.txt";
	var f = file_text_open_append(path);
	var t = _log_template();
	file_text_write_string(f, "[MESSAGE] " + t + "session begin" + "\n");
	file_text_close(f);
	
	gpu_set_tex_mip_enable(mip_off);
	gc_enable(true);
	gc_target_frame_time(100);
#endregion

#region window
	if(OS == os_windows) {
		gameframe_init();
		gameframe_set_cursor = false;
		gameframe_caption_height_normal		= ui(40);
		gameframe_caption_height_maximized  = ui(40);
		
		gameframe_button_array = [  
									game_frame_button_create("", s_kenney, 0, function() {}),
									game_frame_button_create("", s_kenney, 0, function() {}),
								 ];
	} else if(OS == os_macosx)
		mac_window_init();
	
	depth = 0;
	win_wp = WIN_W;
	win_hp = WIN_H;
	win_resize = false;
	
	room_width = WIN_W;
	room_height = WIN_H;
	
	draw_set_circle_precision(64);
	DIALOG_DEPTH_HOVER = 0;
	UPDATE   = RENDER_TYPE.none;
	CURSOR   = cr_default;
	TOOLTIP  = "";
	DRAGGING = noone;
	KEYBOARD_STRING = "";
	RENDER_QUEUE = ds_queue_create();
	
	globalvar AUTO_SAVE_TIMER;
	AUTO_SAVE_TIMER = 0;
	
	_cursor	= CURSOR;
	dc_check = 0;
	kb_time  = 0;
	kb_hold  = false;
	kb_hkey  = 0;
	
	panelInit();
	
	//show_debug_overlay(true);
	//display_set_timing_method(tm_sleep);
	
	addHotkey("", "New file", "N",	MOD_KEY.ctrl, NEW);
	if(!DEMO) {
		addHotkey("", "Save", "S",		MOD_KEY.ctrl, SAVE );
		addHotkey("", "Save as", "S",	MOD_KEY.ctrl | MOD_KEY.shift, SAVE_AS );
		addHotkey("", "Open", "O",		MOD_KEY.ctrl, function() { LOAD(); });
	}
	
	addHotkey("", "Undo", "Z",		MOD_KEY.ctrl, function() { UNDO(); });
	addHotkey("", "Redo", "Z",		MOD_KEY.ctrl | MOD_KEY.shift, function() { REDO(); });
	
	addHotkey("", "Full panel", "`",			MOD_KEY.none, set_focus_fullscreen);
	addHotkey("", "Open notification", vk_f12,	MOD_KEY.none, function() { dialogPanelCall(new Panel_Notification()); });
	
	addHotkey("", "Fullscreen", vk_f11,	MOD_KEY.none, function() { 
		if(gameframe_is_fullscreen_window())
			gameframe_set_fullscreen(0);
		else
			gameframe_set_fullscreen(2);
	});
	
	addHotkey("", "Render all", vk_f5,	MOD_KEY.none, function() { 
		UPDATE |= RENDER_TYPE.full; 
	});
	
	globalvar HOTKEY_MOD;
	HOTKEY_MOD = 0;
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
		for( var i = 0; i < array_length(ANIMATION_PRE); i++ ) 
			ANIMATION_PRE[i]();
	}
	
	function __addon_postAnim() {
		for( var i = 0; i < array_length(ANIMATION_POST); i++ ) 
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
	
	function load_file_path(path) {
		if(!is_array(path)) path = [ path ];
		if(array_length(path) == 0) return; 
		
		var type = "others";
		
		if(array_length(path) == 1 && directory_exists(path[0]))
			type = "image";
			
		for( var i = 0; i < array_length(path); i++ ) {
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
			PANEL_GRAPH.onStepBegin();
			
			var node = noone;
			for( var i = 0; i < array_length(path); i++ ) {
				var p = path[i];
				var ext = string_lower(filename_ext(p));
				
				switch(ext) {
					case ".txt"  :
						node = Node_create_Text_File_Read_path(PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y, p);
						break;
					case ".csv"  :
						node = Node_create_CSV_File_Read_path(PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y, p);
						break;
					case ".json"  :
						node = Node_create_Json_File_Read_path(PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y, p);
						break;
					case ".ase"  :
					case ".aseprite"  :
						node = Node_create_ASE_File_Read_path(PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y, p);
						break;
					case ".png"	 :
					case ".jpg"	 :
					case ".jpeg" :
						node = Node_create_Image_path(PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y, p);
						break;
					case ".gif" :
						node = Node_create_Image_gif_path(PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y, p);
						break;
					case ".obj" :
						node = Node_create_3D_Obj_path(PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y, p);
						break;
					case ".pxc" :
						LOAD_PATH(p);
						break;
					case ".pxcc" :
						APPEND(p);
						break;
				}
				
				PANEL_GRAPH.mouse_grid_y += 160;
			}
			
			if(node)
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
	file_open_parameter = "";
	minimized = false;
	_modified = false;
#endregion

#region dialog
	globalvar DIALOGS;
	DIALOGS = ds_list_create();
#endregion

#region file loader
	global.FILE_LOAD_ASYNC = ds_map_create();
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

#region tween
	tweenInit();
	
	physics_world_update_iterations(100);
#endregion