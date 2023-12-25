/// @description init
if(winMan_isMinimized()) exit;
winManStep()

//print("===== Step start =====");
if(PROJECT.active && !PROJECT.safeMode) { #region
	PROJECT.animator.step();
	PROJECT.globalNode.step();
	LIVE_UPDATE = false;
	
	try {
		if(PANEL_MAIN != 0) PANEL_MAIN.step();
		array_foreach(PROJECT.nodeArray, function(_node) { 
			if(!_node.active) return; 
			_node.triggerCheck(); 
			_node.step(); 
		});
	} catch(e) {
		noti_warning("Step error: " + exception_print(e));
	}
} #endregion

#region hotkey
	HOTKEY_MOD = 0;
	if(CTRL  == KEYBOARD_STATUS.pressing)	HOTKEY_MOD |= MOD_KEY.ctrl;
	if(SHIFT == KEYBOARD_STATUS.pressing)	HOTKEY_MOD |= MOD_KEY.shift;
	if(ALT   == KEYBOARD_STATUS.pressing)	HOTKEY_MOD |= MOD_KEY.alt;
	
	if(!instance_exists(o_dialog_preference) && !HOTKEY_BLOCK) {
		if(ds_map_exists(HOTKEYS, "")) {
			var l = HOTKEYS[? ""];
			for(var i = 0; i < ds_list_size(l); i++) {
				var hotkey = l[| i];
				if(hotkey.key == 0 && hotkey.modi == MOD_KEY.none) continue;
			
				if(key_press(hotkey.key, hotkey.modi)) {
					hotkey.action();
					break;
				}
			}
		}
		
		if(ds_map_exists(HOTKEYS, FOCUS_STR)) {
			var list = HOTKEYS[? FOCUS_STR];
			for(var i = 0; i < ds_list_size(list); i++) {
				var hotkey	= list[| i];
				if(hotkey.key == 0 && hotkey.modi == MOD_KEY.none) continue;
			
				if(key_press(hotkey.key, hotkey.modi)) {
					hotkey.action();
					break;
				}
			}
		}
	}
	
	HOTKEY_BLOCK = false;
#endregion

#region GIF builder
	for( var i = 0; i < ds_list_size(GIF_READER); i++ ) {
		var _reader = GIF_READER[| i];
		
		var _reading = _reader[0].reading();
		if(_reading) {
			var ret = _reader[2];
			ret(new __gif_sprite_builder(_reader[0]));
			ds_stack_push(gif_complete_st, i);
		}
	}
	
	while(!ds_stack_empty(gif_complete_st)) {
		var i = ds_stack_pop(gif_complete_st);
		buffer_delete(GIF_READER[| i][1]);
		delete GIF_READER[| i][0];
		ds_list_delete(GIF_READER, i);
	}
#endregion

#region file drop
	if(OS == os_windows) {
		if(array_length(drop_path)) {
			load_file_path(drop_path);
			drop_path = [];
		}
	} else if(OS == os_macosx) {		
		file_dnd_set_files(file_dnd_pattern, file_dnd_allowfiles, file_dnd_allowdirs, file_dnd_allowmulti);
		file_dnd_filelist = file_dnd_get_files();
		
		if(file_dnd_filelist != "" && _file_dnd_filelist != file_dnd_filelist) {
			var path  = string_trim(file_dnd_filelist);
			load_file_path(string_splice(path, "\n"));
		}
		
		_file_dnd_filelist = file_dnd_filelist;
	}
#endregion

#region window
	if(_modified != PROJECT.modified) {
		_modified = PROJECT.modified;
		
		var cap = "";
		if(PROJECT.safeMode) cap += "[SAFE MODE] ";
		if(PROJECT.readonly) cap += "[READ ONLY] ";
		cap += PROJECT.path + (PROJECT.modified? "*" : "") + " - Pixel Composer";
		
		window_set_caption(cap);
	}
#endregion

#region notification
	if(!ds_list_empty(WARNING)) {
		var rem = ds_stack_create();
		
		for( var i = 0; i < ds_list_size(WARNING); i++ ) {
			var w = WARNING[| i];
			if(--w.life <= 0)
				ds_stack_push(rem, w);
		}
		
		while(!ds_stack_empty(rem)) {
			ds_list_delete(WARNING, ds_stack_pop(rem));	
		}
		
		ds_stack_destroy(rem);
	}
#endregion

#region steam
	steam_update();
	
	if(STEAM_ENABLED) {
		if (steam_is_screenshot_requested()) {
		    var file = "PixelComposer_" + string(irandom_range(100_000, 999_999)) + ".png";
		    screen_save(file);
		    steam_send_screenshot(file, window_get_width(), window_get_height());
		}
	}
#endregion