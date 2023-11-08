/// @description init
global.cache_call = 0;
global.cache_hit  = 0;

HOVERING_ELEMENT  = _HOVERING_ELEMENT;
_HOVERING_ELEMENT = noone;

#region minimize
	if(OS == os_windows && gameframe_is_minimized()) {
		if(!minimized)
			game_set_speed(1, gamespeed_fps);
		minimized = true;
		exit;
	}

	if(minimized) {
		game_set_speed(PREFERENCES.ui_framerate, gamespeed_fps);
		minimized = false;
	}
#endregion

#region window
	//if(keyboard_check_pressed(vk_f12)) DEBUG = !DEBUG;
	
	if(_cursor != CURSOR) {
		window_set_cursor(CURSOR);
		_cursor = CURSOR;
	}
	
	CURSOR = cr_default;
	
	if(!gameframe_is_minimized() && (win_wp != WIN_W || win_hp != WIN_H) && (WIN_W > 1 && WIN_H > 1)) {
		if(!win_resize) CURRENT_PANEL = panelSerialize();
		display_refresh();
		win_resize = true;
	} else 
		win_resize = false;
#endregion

#region focus
	if(mouse_release(mb_any)) DIALOG_CLICK = true;
	
	HOVER = noone;
	with(_p_dialog) checkMouse();
	
	if(PANEL_MAIN != 0) PANEL_MAIN.stepBegin();
	
	DIALOG_DEPTH_HOVER = 0;
	
	with(_p_dialog) checkFocus();
	with(_p_dialog) checkDepth();
	
	with(_p_dialog) doDrag();
	with(_p_dialog) doResize();
#endregion

#region auto save
	AUTO_SAVE_TIMER += delta_time / 1_000_000;
	
	if(PROJECT.modified && PREFERENCES.auto_save_time > 0 && AUTO_SAVE_TIMER > PREFERENCES.auto_save_time) {
		AUTO_SAVE_TIMER = 0;
		var loc = DIRECTORY + "Autosave/";
		if(!directory_exists(loc))
			directory_create(loc);
		
		var fname = string_replace(filename_name(PROJECT.path), filename_ext(PROJECT.path), "") + 
			"_autosave" + string(current_year) + "-" + 
			string_lead_zero(current_month, 2) + "-" + 
			string_lead_zero(current_day, 2) + "T" + 
			string_lead_zero(current_hour, 2) + 
			string_lead_zero(current_minute, 2) + 
			string_lead_zero(current_second, 2) + ".pxc";
		
		try		 { SAVE_AT(PROJECT, loc + fname, "Autosaved "); }
		catch(e) { print(exception_print(e)); }
	}
#endregion

#region render
	//physics_pause_enable(true);
	DEF_SURFACE_RESET();
	
	if(!PROJECT.safeMode) {
		if(UPDATE_RENDER_ORDER) {
			ResetAllNodesRender();
			NodeTopoSort();
		}
		UPDATE_RENDER_ORDER = false;
		
		if(PROJECT.active) {
			array_foreach(PROJECT.nodeArray, function(_node) { if(!_node.active) return; _node.stepBegin(); });
			
			if(IS_PLAYING || IS_RENDERING) {
				if(PROJECT.animator.frame_progress) {
					__addon_preAnim();
				
					if(CURRENT_FRAME == 0)
						ResetAllNodesRender();
					Render(true);
				
					__addon_postAnim();
				}
				PROJECT.animator.frame_progress = false;
			} else {
				if(UPDATE & RENDER_TYPE.full)
					Render();
				else if(UPDATE & RENDER_TYPE.partial)
					Render(true);
			}
		}
	}
	
	UPDATE = RENDER_TYPE.none;
#endregion

#region clicks
	DOUBLE_CLICK = false;
	if(mouse_press(mb_left)) {
		if(dc_check > 0) {
			if(point_distance(mouse_mx, mouse_my, DOUBLE_CLICK_POS[0], DOUBLE_CLICK_POS[1]) < 8)
				DOUBLE_CLICK = true;
			dc_check = 0;
		} else {
			dc_check = PREFERENCES.double_click_delay;
			DOUBLE_CLICK_POS = [ mouse_mx, mouse_my ];
		}
	}
	
	dc_check -= DELTA_TIME;
#endregion

#region step
	if(array_length(action_last_frame) > 0) {
		ds_stack_push(UNDO_STACK, action_last_frame);
		ds_stack_clear(REDO_STACK);
	}
	action_last_frame = [];
#endregion

#region modifiers
	if(CTRL == KEYBOARD_STATUS.up)
		CTRL = KEYBOARD_STATUS.idle;
	if(SHIFT == KEYBOARD_STATUS.up)
		SHIFT = KEYBOARD_STATUS.idle;
	if(ALT == KEYBOARD_STATUS.up)
		ALT = KEYBOARD_STATUS.idle;
	
	if(CTRL == KEYBOARD_STATUS.pressing && !keyboard_check(vk_control))
		CTRL = KEYBOARD_STATUS.up;
	
	if(SHIFT == KEYBOARD_STATUS.pressing && !keyboard_check(vk_shift))
		SHIFT = KEYBOARD_STATUS.up;
	
	if(ALT == KEYBOARD_STATUS.pressing && !keyboard_check(vk_alt))
		ALT = KEYBOARD_STATUS.up;
	
	if(CTRL == KEYBOARD_STATUS.down)
		CTRL  = KEYBOARD_STATUS.pressing;
	
	if(SHIFT == KEYBOARD_STATUS.down)
		SHIFT = KEYBOARD_STATUS.pressing;
	
	if(ALT == KEYBOARD_STATUS.down)
		ALT = KEYBOARD_STATUS.pressing;
	
	if(keyboard_check_pressed(vk_control))
		CTRL = KEYBOARD_STATUS.down;
	if(keyboard_check_pressed(vk_shift))
		SHIFT = KEYBOARD_STATUS.down;
	if(keyboard_check_pressed(vk_alt))
		ALT = KEYBOARD_STATUS.down;
	
	if(keyboard_check_released(vk_control))
		CTRL = KEYBOARD_STATUS.up;
	if(keyboard_check_released(vk_shift))
		SHIFT = KEYBOARD_STATUS.up;
	if(keyboard_check_released(vk_alt))
		ALT = KEYBOARD_STATUS.up;	
#endregion

#region mouse wrap
	MOUSE_WRAPPING = max(0, MOUSE_WRAPPING - 1);
	
	if(MOUSE_WRAP) {
		var _pad = 2;
		
		if(mouse_mx < _pad) {
			window_mouse_set(window_get_width() - _pad, mouse_my);
			MOUSE_WRAPPING = 2;
		} else if(mouse_mx > window_get_width() - _pad) {
			window_mouse_set(_pad, mouse_my);
			MOUSE_WRAPPING = 2;
		}
			
		if(mouse_my < _pad) {
			window_mouse_set(mouse_mx, window_get_height() - _pad);
			MOUSE_WRAPPING = 2;
		} else if(mouse_my > window_get_height() - _pad) {
			window_mouse_set(mouse_mx, _pad);
			MOUSE_WRAPPING = 2;
		}
	}
	MOUSE_WRAP = false;
#endregion

//if(global.cache_call) print($"CACHE called: {global.cache_call} | hit: {global.cache_hit} ({global.cache_hit / global.cache_call * 100}%)");