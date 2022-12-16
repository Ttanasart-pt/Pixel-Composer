/// @description init
#region step
	if(PANEL_MAIN != 0)
		PANEL_MAIN.step();
	
	for(var i = 0; i < ds_list_size(NODES); i++) {
		NODES[| i].step();
	}
#endregion

#region animation
	if(ANIMATOR.is_playing) {
		var fr = ANIMATOR.real_frame + ANIMATOR.framerate * (delta_time / 1000000);
		if(fr <= ANIMATOR.real_frame + 1)
			ANIMATOR.real_frame = fr;
		if(round(ANIMATOR.real_frame) >= ANIMATOR.frames_total) {
			switch(ANIMATOR.playback) {
				case ANIMATOR_END.loop : 
					ANIMATOR.setFrame(0);
					break;
				case ANIMATOR_END.stop : 
					ANIMATOR.setFrame(ANIMATOR.frames_total - 1);
					ANIMATOR.is_playing = false;
					break;
			}
		}
	} else {
		ANIMATOR.setFrame(ANIMATOR.real_frame);
	}
	
	var _c = ANIMATOR.current_frame;
	ANIMATOR.current_frame = round(ANIMATOR.real_frame);
	ANIMATOR.frame_progress = _c != ANIMATOR.current_frame;
#endregion

#region hotkey
	HOTKEY_MOD = 0;
	if(keyboard_check_direct(vk_control))	HOTKEY_MOD |= MOD_KEY.ctrl;
	if(keyboard_check_direct(vk_shift))		HOTKEY_MOD |= MOD_KEY.shift;
	if(keyboard_check_direct(vk_alt))		HOTKEY_MOD |= MOD_KEY.alt;
	
	if(ds_map_exists(HOTKEYS, "")) {
		var l = HOTKEYS[? ""];
		for(var i = 0; i < ds_list_size(l); i++) {
			var hotkey	= l[| i];
			
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
			
			if(hotkey.key != -1) {
				if(key_press(hotkey.key, hotkey.modi)) {
					hotkey.action();
					break;
				}
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
	if (window_command_check(window_command_maximize)) {
		window_command_run(window_command_maximize);
	    PREF_MAP[? "window_maximize"] = !PREF_MAP[? "window_maximize"];
	}
	
	if (window_command_check(window_command_close)) {
		if(MODIFIED && !READONLY) {
			dialogCall(o_dialog_exit);
		} else {
			PREF_SAVE();
			game_end();
		}
	}
	
	if(_modified != MODIFIED) {
		_modified = MODIFIED;
		window_set_caption(CURRENT_PATH + (MODIFIED? "*" : "") + " - Pixel Composer");
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