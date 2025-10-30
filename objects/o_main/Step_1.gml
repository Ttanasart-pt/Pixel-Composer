/// @description init
global.__debug_runner++;
global.cache_call = 0;
global.cache_hit  = 0;

WIDGET_CURRENT_PREV = WIDGET_CURRENT;
HOVERING_ELEMENT    = _HOVERING_ELEMENT;
_HOVERING_ELEMENT   = noone;
FILE_DROPPED        = _FILE_DROPPED;
_FILE_DROPPED       = false;

#region keybord captures
	if(PREFERENCES.keyboard_capture_raw) {
		if(keyboard_string != "") {
			KEYBOARD_PRESSED_STRING = keyboard_string;
			KEYBOARD_STRING += keyboard_string;
			keyboard_string = "";
		}
		
		if(keyboard_check_pressed(vk_backspace)) 
			KEYBOARD_STRING = string_copy(KEYBOARD_STRING, 1, string_length(KEYBOARD_STRING) - 1);
	}
	
	var s = string_decimal(KEYBOARD_STRING, false);
	KEYBOARD_NUMBER = s == ""? undefined : toNumber(s);
	
	key_mod_step();
	
	var _altTab = (keyboard_check_pressed(vk_alt) || keyboard_check(vk_alt)) && (keyboard_check_pressed(vk_tab) || keyboard_check(vk_tab));
	if(_altTab) { KEYBOARD_MOD_RESET } // Dirty hack for Alt+Tab bug in linux
#endregion

#region minimize
	if(winMan_isMinimized()) {
		exit;
		
	} else if(!minimized)
		window_preminimize_rect = [ window_get_x(), window_get_y(), window_get_width(), window_get_height() ];

	if(minimized) {
		window_set_rectangle(window_preminimize_rect[0], window_preminimize_rect[1], window_preminimize_rect[2], window_preminimize_rect[3]);
		minimized = false;
	}
#endregion
	
#region fps
	var  foc     = window_has_focus();
	var _fps_cur = game_get_speed(gamespeed_fps);
	var _fps_tar = foc || GLOBAL_IS_PLAYING? PREFERENCES.ui_framerate : PREFERENCES.ui_framerate_non_focus;
	if(_fps_tar == 0) _fps_tar = 999;
	
	if(_fps_tar != _fps_cur) {
		display_set_timing_method(tm_countvsyncs);
		game_set_speed(_fps_tar, gamespeed_fps);
	}

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
	
	if(foc != windows_focused) {
		windows_focused = foc;
		KEYBOARD_RESET 
		io_clear();
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
	with(_p_dialog) checkMouse();
	if(PANEL_MAIN != 0) PANEL_MAIN.stepBegin();
	
	DIALOG_DEPTH_HOVER = 0;
	
	with(_p_dialog) checkFocus();
	with(_p_dialog) checkDepth();
	
	with(_p_dialog) doResize();
	with(_p_dialog) doDrag();
	
#endregion

#region auto save
	AUTO_SAVE_TIMER += delta_time / 1_000_000;
	
	if(PROJECT.modified && PREFERENCES.auto_save_time > 0 && AUTO_SAVE_TIMER > PREFERENCES.auto_save_time) {
		AUTO_SAVE_TIMER = 0;
		var loc = DIRECTORY + "Autosave/";
		directory_verify(loc);
		
		var fname = $"{filename_name_only(PROJECT.path)}_autosave"
		    + string(current_year)                + "-" 
			+ string_lead_zero(current_month,  2) + "-"
			+ string_lead_zero(current_day,    2) + "T" 
			+ string_lead_zero(current_hour,   2) 
			+ string_lead_zero(current_minute, 2)
			+ string_lead_zero(current_second, 2) 
			+ filename_ext(PROJECT.path);
		
		fname = filename_ext_verify(fname, ".pxc");
		
		try		 { SAVE_AT(PROJECT, loc + fname, new save_param(false, "Autosaved")); }
		catch(e) { print(exception_print(e)); }
	}
#endregion

#region animation & render
	if(RENDERING != undefined) RENDERING.render();
	else if(WILL_RENDERING != undefined) Render(WILL_RENDERING.project, WILL_RENDERING.partial);
	
	if(!surface_exists(watcher_surface)) {
		RENDER_ALL
		watcher_surface = surface_create(1, 1);
	}
	
	DEF_SURFACE_RESET();
	
	if(!PROJECT.safeMode && UPDATE_RENDER_ORDER)
		NodeTopoSort();
	
	if(!LOADING) {
		if(!PROJECT.safeMode) PROJECT.stepBegin();
		
		if(LIVE_UPDATE) RenderSync(PROJECT);
		else if(!PROJECT.safeMode) {
			UPDATE_RENDER_ORDER = false;
			
			if(PROJECT.active) {
				PROJECT.animator.is_simulating = false;
				
				if(PROGRAM_ARGUMENTS._run) {
					if(PROJECT != noone && PROJECT.path != "") {
						exportAll();
						PROGRAM_ARGUMENTS._run = false;
					}
							
				} else if(GLOBAL_IS_PLAYING || GLOBAL_IS_RENDERING) {
					if(PROJECT.animator.frame_progress) {
						__addon_preAnim();
						
						if(IS_CMD) RenderSync(PROJECT, false);
						else       RenderSync(PROJECT, true);
						
						__addon_postAnim();
					}
					PROJECT.animator.frame_progress = false;
					
				} else {
					     if(UPDATE & RENDER_TYPE.full)    Render(PROJECT, false);
					else if(UPDATE & RENDER_TYPE.partial) Render(PROJECT, true);
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
			if(point_distance(mouse_mx, mouse_my, dclick[0], dclick[1]) < 8)
				DOUBLE_CLICK = true;
			dc_check = 0;
			
		} else {
			dc_check = PREFERENCES.double_click_delay;
			dclick = [ mouse_mx, mouse_my ];
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
#endregion

#region cmd
	var _resPath = program_directory + "in";
	if(IS_CMD && file_exists(_resPath)) {
		var cmd = file_read_all(_resPath);
		cmd_submit(cmd);
		file_delete(_resPath);
	}
#endregion

#region random debug
	//print(typeof(WIDGET_CURRENT), instanceof(WIDGET_CURRENT));
	//if(global.cache_call) print($"CACHE called: {global.cache_call} | hit: {global.cache_hit} ({global.cache_hit / global.cache_call * 100}%)");
	//print($"{is_struct(HOVER)? instanceof(HOVER) : HOVER}, {is_struct(FOCUS)? instanceof(FOCUS) : FOCUS}");
	//print($"{mouse_mx}, {mouse_my}");
#endregion