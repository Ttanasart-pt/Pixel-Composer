/// @description init
if(PREFERENCES.multi_window) winwin_update();

// print($"{TOOLTIP_WINDOW}, {winwin_get_focus()}");
// print(keyboard_check(vk_space));

global.__debug_runner++;
global.cache_call = 0;
global.cache_hit  = 0;

HOVERING_ELEMENT  = _HOVERING_ELEMENT;
_HOVERING_ELEMENT = noone;
FILE_DROPPED      = _FILE_DROPPED;
_FILE_DROPPED     = false;

#region keybord captures
	if(PREFERENCES.keyboard_capture_raw && keyboard_string != "") {
		KEYBOARD_STRING = keyboard_string;
		keyboard_string = "";
	}
#endregion

#region minimize
	if(winMan_isMinimized()) {
		if(!minimized) game_set_speed(1, gamespeed_fps);
		minimized = true;
		exit;
		
	} else if(!minimized)
		window_preminimize_rect = [ window_get_x(), window_get_y(), window_get_width(), window_get_height() ];

	if(minimized) {
		window_set_rectangle(window_preminimize_rect[0], window_preminimize_rect[1], window_preminimize_rect[2], window_preminimize_rect[3]);
		minimized = false;
	}
	
	var foc = window_has_focus();
	//if(HOVER && instance_exists(HOVER) && HOVER.window != noone) 
	if(PREFERENCES.multi_window)
		foc = true;
	
	game_set_speed(foc || IS_PLAYING? PREFERENCES.ui_framerate : PREFERENCES.ui_framerate_non_focus, gamespeed_fps);
	WINDOW_ACTIVE = noone;
#endregion

#region fpss
	if(fpsr++ % 5 == 0) {
		var ff = 0;
		for( var i = 1; i < 10; i++ ) {
			fpss[i] = fpss[i - 1]
			ff += fpss[i];
		}
		fpss[0] = fps_real;
		ff     += fps_real;
		FPS_REAL = round(ff / 10);
	}
#endregion

#region window & mouse
	//if(keyboard_check_pressed(vk_f12)) DEBUG = !DEBUG;
	
	global_mouse_pool_init();
	mouse_step();
	
	if(_cursor != CURSOR) {
		window_set_cursor(CURSOR);
		_cursor = CURSOR;
	} 
	CURSOR = cr_default;
	
	if(_cursor_lock != CURSOR_LOCK) {
		window_mouse_set_locked(CURSOR_LOCK);
		if(!CURSOR_LOCK) window_mouse_set(CURSOR_LOCK_X, CURSOR_LOCK_Y);
	}
	
	_cursor_lock   = CURSOR_LOCK;
	CURSOR_IS_LOCK = CURSOR_LOCK;
	CURSOR_LOCK    = false;
	
	if(!is_surface(watcher_surface)) {
		RENDER_ALL
		watcher_surface = surface_create(1, 1);
	}
	
	if(PEN_POOL <= 0) PEN_USE = false;
	else              PEN_POOL--;
	
	PEN_RELEASED      = false;
	PEN_RIGHT_PRESS   = false;
	PEN_RIGHT_RELEASE = false;
	
	PEN_X_DELTA = 0;
	PEN_Y_DELTA = 0;
	
	if(!IS_CMD) tabletstuff_perform_event(id, ev_other, ev_user10);
	
	//print($"{PEN_RIGHT_CLICK} | {PEN_RIGHT_PRESS}, {PEN_RIGHT_RELEASE}");
	//print($"{mouse_x}, {mouse_y}");
#endregion

#region focus
	if(mouse_release(mb_any)) DIALOG_CLICK = true;
	
	HOVER = noone;
	with(_p_dialog) checkMouse();		WINDOW_ACTIVE = noone;
	
	if(PANEL_MAIN != 0) PANEL_MAIN.stepBegin();
	
	DIALOG_DEPTH_HOVER = 0;
	
	with(_p_dialog) checkFocus();		WINDOW_ACTIVE = noone;
	with(_p_dialog) checkDepth();		WINDOW_ACTIVE = noone;
	
	with(_p_dialog) doResize();			WINDOW_ACTIVE = noone;
	with(_p_dialog) doDrag();			WINDOW_ACTIVE = noone;
#endregion

#region auto save
	AUTO_SAVE_TIMER += delta_time / 1_000_000;
	
	if(PROJECT.modified && PREFERENCES.auto_save_time > 0 && AUTO_SAVE_TIMER > PREFERENCES.auto_save_time) {
		AUTO_SAVE_TIMER = 0;
		var loc = DIRECTORY + "Autosave/";
		directory_verify(loc);
		
		var fname = string_replace(filename_name(PROJECT.path), filename_ext(PROJECT.path), "") + 
			"_autosave" + string(current_year) + "-" + 
			string_lead_zero(current_month, 2) + "-" + 
			string_lead_zero(current_day, 2) + "T" + 
			string_lead_zero(current_hour, 2) + 
			string_lead_zero(current_minute, 2) + 
			string_lead_zero(current_second, 2) + filename_ext(PROJECT.path);
		
		try		 { SAVE_AT(PROJECT, loc + fname, "Autosaved "); }
		catch(e) { print(exception_print(e)); }
	}
#endregion

#region animation & render
	DEF_SURFACE_RESET();
	
	if(!PROJECT.safeMode && UPDATE_RENDER_ORDER) {
		// ResetAllNodesRender();
		NodeTopoSort();
	}
	
	if(!LOADING) {
		if(!PROJECT.safeMode) array_foreach(PROJECT.allNodes, function(_node) /*=>*/ { if(!_node.active) return; _node.stepBegin(); });
	
		if(LIVE_UPDATE)
			Render();
		else if(!PROJECT.safeMode) {
			UPDATE_RENDER_ORDER = false;
			
			if(PROJECT.active) {
				PROJECT.animator.is_simulating = false;
				
				if(PROGRAM_ARGUMENTS._run) {
					if(PROJECT != noone && PROJECT.path != "") {
						exportAll();
						PROGRAM_ARGUMENTS._run = false;
					}
							
				} else if(IS_PLAYING || IS_RENDERING) {
					if(PROJECT.animator.frame_progress) {
						__addon_preAnim();
						
						if(IS_FIRST_FRAME)
							ResetAllNodesRender();
							
						if(IS_CMD) Render(false);
						else       Render(true);
						
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
	
		if(PROGRAM_ARGUMENTS._rendering && PROGRAM_ARGUMENTS._run == false && array_empty(PROGRAM_ARGUMENTS._exporting)) {
			log_console($"Export {CLI_EXPORT_AMOUNT} {CLI_EXPORT_AMOUNT > 1? "files" : "file"} completed");
			
			if(PROGRAM_ARGUMENTS._persist) {
				PROGRAM_ARGUMENTS._rendering = false;
				cli_wait();
			} else
				game_end();
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

#region actions
	if(array_length(action_last_frame) > 0) {
		ds_stack_push(UNDO_STACK, action_last_frame);
		ds_stack_clear(REDO_STACK);
	}
	action_last_frame = [];
#endregion

#region modifiers
	var _d = PREFERENCES.double_click_delay;
	
	kd_ctrl  += DELTA_TIME;
	if(CTRL  == KEY_STAT.up) 										CTRL  = KEY_STAT.idle;
	if(CTRL  == KEY_STAT.pressing && !keyboard_check(vk_control))	CTRL  = KEY_STAT.up;
	if(CTRL  == KEY_STAT.down || CTRL  == KEY_STAT.double)			CTRL  = KEY_STAT.pressing;
	if(keyboard_check_pressed(vk_control))						  { CTRL  = kd_ctrl < _d?  KEY_STAT.double : KEY_STAT.down;  kd_ctrl  = 0; }
	if(keyboard_check_released(vk_control)) 						CTRL  = KEY_STAT.up;
	
	kd_shift += DELTA_TIME;
	if(SHIFT == KEY_STAT.up)                                     	SHIFT = KEY_STAT.idle;
	if(SHIFT == KEY_STAT.pressing && !keyboard_check(vk_shift))  	SHIFT = KEY_STAT.up;
	if(SHIFT == KEY_STAT.down || SHIFT == KEY_STAT.double)         	SHIFT = KEY_STAT.pressing;
	if(keyboard_check_pressed(vk_shift))                          { SHIFT = kd_shift < _d? KEY_STAT.double : KEY_STAT.down;  kd_shift = 0; }
	if(keyboard_check_released(vk_shift))                       	SHIFT = KEY_STAT.up;
	
	kd_alt   += DELTA_TIME;
	if(ALT   == KEY_STAT.up)                                     	ALT   = KEY_STAT.idle;
	if(ALT   == KEY_STAT.pressing && !keyboard_check(vk_alt))    	ALT   = KEY_STAT.up;
	if(ALT   == KEY_STAT.down || ALT   == KEY_STAT.double)          ALT   = KEY_STAT.pressing;
	if(keyboard_check_pressed(vk_alt))                            { ALT   = kd_alt < _d?   KEY_STAT.double : KEY_STAT.down;  kd_alt   = 0; }
	if(keyboard_check_released(vk_alt))                         	ALT   = KEY_STAT.up;	
	
	HOTKEY_MOD = 0;
	if(CTRL  == KEY_STAT.pressing)									HOTKEY_MOD |= MOD_KEY.ctrl;
	if(SHIFT == KEY_STAT.pressing)									HOTKEY_MOD |= MOD_KEY.shift;
	if(ALT   == KEY_STAT.pressing)									HOTKEY_MOD |= MOD_KEY.alt;
	
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

#region depth
	if(_use_depth != USE_DEPTH) {
		_use_depth = USE_DEPTH;
		surface_depth_disable(!USE_DEPTH);
	}
	
	USE_DEPTH = false;
#endregion

#region cmd
	var _resPath = program_directory + "in";
	
	if(file_exists(_resPath)) {
		var cmd = file_read_all(_resPath);
		cmd_submit(cmd);
		file_delete(_resPath);
	}
#endregion

//if(global.cache_call) print($"CACHE called: {global.cache_call} | hit: {global.cache_hit} ({global.cache_hit / global.cache_call * 100}%)");
//print($"{is_struct(HOVER)? instanceof(HOVER) : HOVER}, {is_struct(FOCUS)? instanceof(FOCUS) : FOCUS}");
//print($"{mouse_mx}, {mouse_my}");