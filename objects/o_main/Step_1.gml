/// @description init
if(MULTI_WINDOWS) winwin_update();
global.__debug_runner++;
global.cache_call = 0;
global.cache_hit  = 0;

DIALOG_JUST_CLOSED  = false;
WIDGET_CURRENT_PREV = WIDGET_CURRENT;
HOVERING_ELEMENT    = _HOVERING_ELEMENT;
_HOVERING_ELEMENT   = noone;
FILE_DROPPED        = _FILE_DROPPED;
_FILE_DROPPED       = false;

if(os_is_paused()) OS_PAUSED = true;

#region Keybord captures
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

#region Minimize
	if(winMan_isMinimized()) {
		exit;
		
	} else if(!minimized)
		window_preminimize_rect = [ WIN_X, WIN_Y, window_get_width(), window_get_height() ];

	if(minimized) {
		window_set_rectangle(window_preminimize_rect[0], window_preminimize_rect[1], window_preminimize_rect[2], window_preminimize_rect[3]);
		minimized = false;
	}
#endregion
	
#region Windows focus
	HOVER_WINDOW = undefined;
	FOCUS_WINDOW = undefined;
	var foc = false;
	
	if(OS == os_windows) {
		if(window_has_focus()) {
			HOVER_WINDOW = 1;
			FOCUS_WINDOW = 1;
			foc = true;
		}
		
		if(FILE_IS_DROPPING || FILE_DROPPED) {
			HOVER_WINDOW = 1;
			FOCUS_WINDOW = 1;
		}
		
		if(MULTI_WINDOWS) {
			if(winwin_mouse_is_over(winwin_main))
				HOVER_WINDOW = 1;
				
			for( var i = 0, n = array_length(WINWIN_ALL); i < n; i++ ) {
				if(winwin_mouse_is_over(WINWIN_ALL[i]))
					HOVER_WINDOW = WINWIN_ALL[i];
					
				if(winwin_has_focus(WINWIN_ALL[i])) {
					FOCUS_WINDOW = WINWIN_ALL[i];
					foc = true;
				}
				
			}
			
		}
		
	} else {
		if(!OS_PAUSED) {
			HOVER_WINDOW = 1;
			FOCUS_WINDOW = 1;
			foc = true;
		}
	}
	
	if(CLICK_REFRESH) {
		CLICK_REFRESH = false;
		display_refresh();
	}
#endregion

#region FPS
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

#region Window & Mouse
	mouse_step();
	
	if(OS_PAUSED && mouse_press(mb_any)) OS_PAUSED = false;
	
	if(_cursor != CURSOR) {
		window_set_cursor(CURSOR);
		for( var i = 0, n = array_length(WINWIN_ALL); i < n; i++ ) 
			winwin_set_cursor(WINWIN_ALL[i], CURSOR);
		
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
	
	if(PEN_POOL <= 0) {
		if(PEN_USE) {
			MOUSE_EVENT.lrelease = true;
			PEN_USE = false;
		}
		
	} else PEN_POOL--;
	
	PEN_RELEASED      = false;
	PEN_RIGHT_PRESS   = false;
	PEN_RIGHT_RELEASE = false;
	
	PEN_X_DELTA = 0;
	PEN_Y_DELTA = 0;
	
	if(!IS_CMD) tabletstuff_perform_event(id, ev_other, ev_user10);
	
	// print($"{PEN_USE} : {PEN_CONTACT} > {PEN_RIGHT_CLICK} | {PEN_RIGHT_PRESS}, {PEN_RIGHT_RELEASE}");
	// print($"{mouse_mxs}, {mouse_mys}");
#endregion

#region Hover & Focus
	if(mouse_release(mb_any)) DIALOG_CLICK = true;
	
	HOVER = noone;
	DIALOG_DEPTH_HOVER = 0;
	
	if(PANEL_MAIN)   PANEL_MAIN.checkMouse();
	with(_p_dialog)  checkMouse();
	with(o_pie_menu) checkMouse();
		
	if(PANEL_MAIN)   PANEL_MAIN.checkFocus();
	with(_p_dialog)  checkFocus();
	with(o_pie_menu) checkFocus();
	
	// print("hover|", typeof(HOVER), instanceof(HOVER), HOVER);
	if(is(HOVER, PanelContent)) HOVER.panel.checkHover();
	
	with(_p_dialog)  checkDepth();
	with(o_pie_menu) checkDepth();
	
	with(_p_dialog)  doResize();
	with(_p_dialog)  doDrag();
	
	if(PANEL_MAIN)   PANEL_MAIN.stepBegin();
	
	 HIGHLIGHT_PROP = _HIGHLIGHT_PROP;
	_HIGHLIGHT_PROP = undefined;
#endregion

#region Auto Save
	AUTO_SAVE_TIMER += delta_time / 1_000_000;
	
	if(PROJECT.modified && PREFERENCES.auto_save_time > 0 && AUTO_SAVE_TIMER > PREFERENCES.auto_save_time) {
		AUTO_SAVE_TIMER = 0;
		SAVE_AUTO(PROJECT);
	}
#endregion

#region Animation & Render
	if(RENDERING != undefined) {
		if(RENDERING.render())
			RENDERING = undefined;
		
	} else if(WILL_RENDERING != undefined) Render(WILL_RENDERING.project, WILL_RENDERING.partial);
	
	if(!surface_exists(watcher_surface)) {
		RenderAll();
		watcher_surface = surface_create(1, 1);
	}
	
	DEF_SURFACE_RESET();
	
	if(!PROJECT.safeMode && UPDATE_RENDER_ORDER) {
		try { NodeTopoSort(); } 
		catch(e) { exception_print(e); }
	}
	
	if(IS_CMD) {
		if(PROJECT.path == "" || LOADING) exit;
		switch(PROGRAM_ARGUMENTS._rendering) {
			case 1 :
				RenderSync(PROJECT, false);
				exportAll();
				PROGRAM_ARGUMENTS._rendering = 2;
				break;
				
			case 2: 
				if(array_empty(PROGRAM_ARGUMENTS._exporting)) {
					log_console($"Export {CLI_EXPORT_AMOUNT} {CLI_EXPORT_AMOUNT > 1? "files" : "file"} completed");
					
					if(PROGRAM_ARGUMENTS._persist) {
						PROGRAM_ARGUMENTS._rendering = false;
						cli_wait();
						
					} else {
						show_debug_message("Export Complete. Persist mode off, exiting...");
						game_end();
					}
				}
				break;
		}
		
	} else if(!LOADING) {
		if(!PROJECT.safeMode) PROJECT.stepBegin();
		
		if(LIVE_UPDATE) RenderSync(PROJECT);
		else if(!PROJECT.safeMode) {
			UPDATE_RENDER_ORDER = false;
			
			if(PROJECT.active) {
				PROJECT.animator.is_simulating = false;
				
				if(GLOBAL_IS_PLAYING || GLOBAL_IS_RENDERING) {
					if(PROJECT.animator.frame_progress) {
						__addon_preAnim();
						RenderSync(PROJECT, !IS_CMD);
						__addon_postAnim();
					}
						
					PROJECT.animator.frame_progress = false;
					
				} else {
					     if(UPDATE & RENDER_TYPE.full)    Render(PROJECT, false);
					else if(UPDATE & RENDER_TYPE.partial) Render(PROJECT, true);
				}
			}
		}
	}
	
	UPDATE = RENDER_TYPE.none;
#endregion

#region Clicks
	DOUBLE_CLICK = false;
	if(mouse_lpress()) {
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

#region Actions
	if(array_length(action_last_frame) > 0) {
		ds_stack_push(UNDO_STACK, action_last_frame);
		ds_stack_clear(REDO_STACK);
	}
	action_last_frame = [];
#endregion

#region Mouse wrap
	MOUSE_WRAPPING = max(0, MOUSE_WRAPPING - 1);
	
	if(MOUSE_WRAP) {
		var _pad = 2;
		var _mx0 = MOUSE_WRAP_MON[0];
		var _my0 = MOUSE_WRAP_MON[1];
		var _mx1 = MOUSE_WRAP_MON[2];
		var _my1 = MOUSE_WRAP_MON[3];
		
		if(mouse_rx < _mx0 + _pad) {
			window_mouse_set(_mx1 - _pad - WIN_X, mouse_ry - WIN_Y);
			MOUSE_WRAPPING = 2;
			
		} else if(mouse_rx > _mx1 - _pad) {
			window_mouse_set(_mx0 + _pad - WIN_X, mouse_ry - WIN_Y);
			MOUSE_WRAPPING = 2;
		}
			
		if(mouse_ry < _my0 + _pad) {
			window_mouse_set(mouse_rx - WIN_X, _my1 - _pad - WIN_Y);
			MOUSE_WRAPPING = 2;
			
		} else if(mouse_ry > _my1 - _pad) {
			window_mouse_set(mouse_rx - WIN_X, _my0 + _pad - WIN_Y);
			MOUSE_WRAPPING = 2;
		}
	}
	
	MOUSE_WRAP = false;
#endregion

#region Depth
	if(_use_depth != USE_DEPTH) {
		_use_depth = USE_DEPTH;
		surface_depth_disable(!USE_DEPTH);
	}
#endregion

#region CMD
	var _resPath = program_directory + "in";
	if(IS_CMD && file_exists(_resPath)) {
		var cmd = file_read_all(_resPath);
		cmd_submit(cmd);
		file_delete(_resPath);
	}
#endregion