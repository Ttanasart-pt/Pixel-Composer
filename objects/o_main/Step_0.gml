/// @description init
#region animation
	ANIMATOR.frame_progress = false;
	
	if(ANIMATOR.is_playing && ANIMATOR.play_freeze == 0) {
		ANIMATOR.time_since_last_frame += ANIMATOR.framerate * (delta_time / 1000000);
		
		if(ANIMATOR.time_since_last_frame >= 1)
			ANIMATOR.setFrame(ANIMATOR.real_frame + 1);
	} else {
		ANIMATOR.setFrame(ANIMATOR.real_frame);
		ANIMATOR.time_since_last_frame = 0;
	}
	
	ANIMATOR.play_freeze = max(0, ANIMATOR.play_freeze - 1);
#endregion

#region step
	//VARIABLE.step();
	
	try {
		if(PANEL_MAIN != 0)
			PANEL_MAIN.step();
	
		for(var i = 0; i < ds_list_size(NODES); i++) {
			NODES[| i].step();
		}
	} catch(e) 
		noti_warning("Step error: " + exception_print(e));
#endregion

#region hotkey
	HOTKEY_MOD = 0;
	if(CTRL  == KEYBOARD_STATUS.pressing)	HOTKEY_MOD |= MOD_KEY.ctrl;
	if(SHIFT == KEYBOARD_STATUS.pressing)	HOTKEY_MOD |= MOD_KEY.shift;
	if(ALT   == KEYBOARD_STATUS.pressing)	HOTKEY_MOD |= MOD_KEY.alt;
	
	if(ds_map_exists(HOTKEYS, "")) {
		var l = HOTKEYS[? ""];
		for(var i = 0; i < ds_list_size(l); i++) {
			var hotkey = l[| i];
			var name = hotkey.name;
			
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
			
			if(hotkey.key != -1 && key_press(hotkey.key, hotkey.modi)) {
				hotkey.action();
				break;
			}
		}
	}
#endregion

#region coroutine
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
	if(array_length(drop_path)) {
		load_file_path(drop_path);
		drop_path = [];
	}
#endregion

#region window
	if(_modified != MODIFIED) {
		_modified = MODIFIED;
		
		var cap = "";
		if(SAFE_MODE)	cap += "[SAFE MODE] ";
		if(READONLY)	cap += "[READ ONLY] ";
		cap += CURRENT_PATH + (MODIFIED? "*" : "") + " - Pixel Composer";
		
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