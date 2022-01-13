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
		ANIMATOR.real_frame += ANIMATOR.framerate / room_speed;
		if(floor(ANIMATOR.real_frame) > ANIMATOR.frames_total) {
			switch(ANIMATOR.playback) {
				case ANIMATOR_END.loop : 
					ANIMATOR.real_frame = 0;
					break;
				case ANIMATOR_END.stop : 
					ANIMATOR.real_frame = ANIMATOR.frames_total;
					ANIMATOR.is_playing = false;
					break;
			}
		}
	} else {
		ANIMATOR.real_frame = min(ANIMATOR.real_frame, ANIMATOR.frames_total);
	}
	
	ANIMATOR.frame_progress = false;
	var _c = ANIMATOR.current_frame;
	ANIMATOR.current_frame = floor(ANIMATOR.real_frame);
	
	if(_c != ANIMATOR.current_frame) {
		ANIMATOR.frame_progress = true;
	}
#endregion

#region hotkey
	HOTKEY_MOD = 0;
	if(keyboard_check_direct(vk_control))	HOTKEY_MOD |= MOD_KEY.ctrl;
	if(keyboard_check_direct(vk_shift))		HOTKEY_MOD |= MOD_KEY.shift;
	if(keyboard_check_direct(vk_alt))		HOTKEY_MOD |= MOD_KEY.alt;
	
	//show_debug_message(HOTKEY_MOD)
	
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

