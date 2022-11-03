/// @description init
#region log
	var path = "log_temp.txt";
	var f = file_text_open_append(path);
	var t = _log_template();
	file_text_write_string(f, "[MESSAGE] " + t + "session begin" + "\n");
	
	if (!code_is_compiled()) {
		file_text_write_string(f, "[ERROR] " + t + "code not compiled" + "\n");
	}
	
	file_text_close(f);
#endregion

//display_reset(8, 1);

#region window
	depth = 0;
	win_wp = WIN_W;
	win_hp = WIN_H;
	
	room_width = WIN_W;
	room_height = WIN_H;
	
	draw_set_circle_precision(64);
	globalvar CURSOR, UPDATE, TOOLTIP, DIALOG_DEPTH_HOVER;
	globalvar RENDER_STACK;
	DIALOG_DEPTH_HOVER = 0;
	UPDATE  = RENDER_TYPE.none;
	CURSOR  = cr_default;
	TOOLTIP = "";
	RENDER_STACK = ds_stack_create();
	
	_cursor	= CURSOR;
	dc_check = 0;
	
	display_set_timing_method(tm_sleep);
	
	addHotkey("", "New file", "N",	MOD_KEY.ctrl, NEW);
	addHotkey("", "Save", "S",		MOD_KEY.ctrl, SAVE);
	addHotkey("", "Save as", "S",	MOD_KEY.ctrl | MOD_KEY.shift, SAVE_AS);
	addHotkey("", "Open", "O",		MOD_KEY.ctrl, function() { LOAD(); });
	
	addHotkey("", "Undo", "Z",		MOD_KEY.ctrl, function() { UNDO(); });
	addHotkey("", "Redo", "Z",		MOD_KEY.ctrl | MOD_KEY.shift, function() { REDO(); });
	
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
	file_dnd_set_hwnd(window_handle());
	file_dnd_set_enabled(true);
	file_dnd_filelist   = "";
	file_dropping		= "";
	file_dnd_pattern    = "*.*";
	file_dnd_allowfiles = true;
	file_dnd_allowdirs  = true;
	file_dnd_allowmulti = true;
	
	function load_file_path(path, _new = false) {
		if(string_pos("\n", path) == 1) path = string_replace(path, "\n", "");
		
		var is_multi = string_pos("\n", path) != 0 || directory_exists(path);
		
		if(is_multi) {
			with(dialogCall(o_dialog_add_multiple_images, WIN_W / 2, WIN_H / 2)) {
				setPath(path);	
			}
		} else {
			PANEL_GRAPH.stepBegin();
			var ext = filename_ext(path);
			
			switch(ext) {
				case ".png"	 :
				case ".jpg"	 :
				case ".jpeg" :
					Node_create_Image_path(PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y, path);
					break;
				case ".gif"  :
					Node_create_Image_gif_path(PANEL_GRAPH.mouse_grid_x, PANEL_GRAPH.mouse_grid_y, path);
					break;
				case ".json" :
				case ".pxc" :
					if(_new) NEW();
					LOAD_PATH(path);
					break;
			}
			PANEL_GRAPH.fullView();
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