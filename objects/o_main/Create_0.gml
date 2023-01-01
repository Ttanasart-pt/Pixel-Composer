/// @description init
#region log
	var path = "log_temp.txt";
	var f = file_text_open_append(path);
	var t = _log_template();
	file_text_write_string(f, "[MESSAGE] " + t + "session begin" + "\n");
	
	file_text_close(f);
#endregion

#region window
	depth = 0;
	win_wp = WIN_W;
	win_hp = WIN_H;
	
	room_width = WIN_W;
	room_height = WIN_H;
	
	draw_set_circle_precision(64);
	DIALOG_DEPTH_HOVER = 0;
	UPDATE  = RENDER_TYPE.none;
	CURSOR  = cr_default;
	TOOLTIP = "";
	KEYBOARD_STRING = "";
	RENDER_STACK = ds_stack_create();
	
	_cursor	= CURSOR;
	dc_check = 0;
	kb_time  = 0;
	kb_hold  = false;
	kb_hkey  = 0;
	
	//display_set_timing_method(tm_sleep);
	
	addHotkey("", "New file", "N",	MOD_KEY.ctrl, NEW);
	addHotkey("", "Save", "S",		MOD_KEY.ctrl, SAVE);
	addHotkey("", "Save as", "S",	MOD_KEY.ctrl | MOD_KEY.shift, SAVE_AS);
	addHotkey("", "Open", "O",		MOD_KEY.ctrl, function() { LOAD(); });
	
	addHotkey("", "Undo", "Z",		MOD_KEY.ctrl, function() { UNDO(); });
	addHotkey("", "Redo", "Z",		MOD_KEY.ctrl | MOD_KEY.shift, function() { REDO(); });
	
	addHotkey("", "Full panel", vk_tab,	MOD_KEY.none, set_focus_fullscreen);
	
	addHotkey("", "Render all", vk_f5,	MOD_KEY.none, function() { 
		UPDATE |= RENDER_TYPE.full; 
	});
	
	globalvar HOTKEY_MOD;
	HOTKEY_MOD = 0;
#endregion

#region coroutine
	globalvar GIF_READER;
	GIF_READER = ds_list_create();
	gif_complete_st = ds_stack_create();
#endregion

#region file drop
	file_dropper_init();
	drop_path = [];
	
	function load_file_path(path) {
		if(array_length(path) == 0) return; 
		var is_multi = array_length(path) > 1 || directory_exists(path[0]);
		
		if(is_multi) {
			with(dialogCall(o_dialog_add_multiple_images, WIN_W / 2, WIN_H / 2)) {
				setPath(path);	
			}
		} else {
			PANEL_GRAPH.onStepBegin();
			path = path[0];
			var ext = filename_ext(path);
			var node = noone;
			
			switch(ext) {
				case ".txt"  :
					node = Node_create_Text_File_Read_path(PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y, path);
					break;
				case ".json"  :
					node = Node_create_Json_File_Read_path(PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y, path);
					break;
				case ".png"	 :
				case ".jpg"	 :
				case ".jpeg" :
					node = Node_create_Image_path(PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y, path);
					break;
				case ".gif"  :
					node = Node_create_Image_gif_path(PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y, path);
					break;
				case ".obj" :
					node = Node_create_3D_Obj_path(PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y, path);
					break;
				case ".pxc" :
					LOAD_PATH(path);
					break;
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
	if(os_is_network_connected()) {
		var version = "https://gist.githubusercontent.com/Ttanasart-pt/d9eefbda84a78863c122b8b155bc0cda/raw/version.txt";
		version_check = http_get(version);
	}
#endregion

#region parameter
	file_open_parameter = "";
	
	window_command_hook(window_command_maximize);
	window_command_hook(window_command_close);
	
	_modified = false;
#endregion

#region dialog
	globalvar DIALOGS;
	DIALOGS = ds_list_create();
#endregion