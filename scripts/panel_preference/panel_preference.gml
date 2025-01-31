function Panel_Preference() : PanelContent() constructor {
	
	title = "Preference";
	w = min(WIN_W - ui(16), ui(1000));
	h = min(WIN_H - ui(16), ui(700));
	min_w    = ui(640);
	min_h    = ui(480);
	auto_pin = true;
	
	page_width     = ui(128);
	should_restart = false;
	padding        = ui(8);
	
	font = f_p2;
    
	panel_width   = w - padding * 2 - page_width;
	panel_height  = h - padding * 2;
	
	hotkey_cont_h = ui(240);
	hotkey_height = panel_height - hotkey_cont_h - ui(32);
    
    #region pages
    	page_current = 0;
    	page[0] = __txtx("pref_pages_general", "General");
    	page[1] = __txtx("pref_pages_interface", "Interface");
    	page[2] = __txt("Nodes");
    	page[3] = __txt("Theme");
    	page[4] = __txt("Hotkeys");
    	
    	section_current = "";
    	sections  = array_create(array_length(page));
    	collapsed = {};
    	
    	sp_page = new scrollPane(page_width - ui(4), panel_height, function(_y, _m) {
    		draw_clear_alpha(COLORS.panel_bg_clear, 1);
    		var ww = sp_page.surface_w;
    		var hh = 0;
    		
    		var yl = _y;
    		var hg = line_get_height(f_p1, 8);
    		var hs = line_get_height(f_p2, 8);
    		
    		for(var i = 0; i < array_length(page); i++) {
    			if(i == page_current) draw_set_text(f_p1b, fa_left, fa_center, COLORS._main_text_accent);
    			else                  draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text_inner);
    			
    			if(pHOVER && point_in_rectangle(_m[0], _m[1], 0, yl, ww, yl + hg - 1)) {
    				sp_page.hover_content = true;
    				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, yl, ww, hg, CDEF.main_white, 1);
    				
    				if(i != page_current && mouse_click(mb_left, pFOCUS)) {
    					page_current = i;
    					sp_pref.setScroll(0);
    				}
    			}
    		
    			draw_text_add(ui(8), yl + hg / 2, page[i]);
    			yl += hg;
    			hh += hg;
    			
    			if(i == page_current && sections[i] != 0) {
    				for( var j = 0, m = array_length(sections[i]); j < m; j++ ) {
    					var sect = sections[i][j];
    				
    					draw_set_text(f_p2, fa_left, fa_center, section_current == sect[0]? COLORS._main_text : COLORS._main_text_sub);
    				
    					if(pHOVER && point_in_rectangle(_m[0], _m[1], 0, yl, ww, yl + hs - 1)) {
    						sp_page.hover_content = true;
    						if(mouse_press(mb_left, pFOCUS))
    							sect[1].scroll_y_to = -sect[2];
    					
    						draw_set_color(COLORS._main_text);
    					}
    				
    					var _xx = ui(8 + 16);
    					var sect_title = sect[0];
    					var sp = string_split(sect_title, " ");
    					if(sp[0] == "-") {
    						_xx += ui(16);
    						sect_title = string_replace(sect_title, "- ", "");
    					}
    					
    					draw_text_add(_xx, yl + hs / 2, __txt(sect_title));
    				
    					yl += hs;
    					hh += hs;
    				}
    			}
    		}
    		
    		return hh;
    	});
    	
    	sp_page.show_scroll   = false;
    #endregion
    
    #region general
    	pref_global = ds_list_create();
    	
    	ds_list_add(pref_global, __txt("Inputs"));
    	
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_double_click_delay", "Double click delay"),
    			"double_click_delay",
    			slider(0, 1, 0.01, function(val) /*=>*/ { PREFERENCES.double_click_delay = val; PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_mouse_wheel_speed", "Scroll speed"),
    			"mouse_wheel_speed",
    			new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { PREFERENCES.mouse_wheel_speed = val; PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_keyboard_hold_start", "Keyboard hold start"),
    			"keyboard_repeat_start",
    			slider(0, 1, 0.01, function(val) /*=>*/ { PREFERENCES.keyboard_repeat_start = val; PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_keyboard_repeat_delay", "Keyboard repeat delay"),
    			"keyboard_repeat_speed",
    			slider(0, 1, 0.01, function(val) /*=>*/ { PREFERENCES.keyboard_repeat_speed = val; PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_expand_hovering_panel", "Expand hovering panel"),
    			"expand_hover",
    			new checkBox(function() /*=>*/ { PREFERENCES.expand_hover = !PREFERENCES.expand_hover; PREF_SAVE(); })
    		));
    	
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_expand_lock_mouse_slider", "Lock mouse when sliding"),
    			"slider_lock_mouse",
    			new checkBox(function() /*=>*/ { PREFERENCES.slider_lock_mouse = !PREFERENCES.slider_lock_mouse; PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_pen_pool_delay", "Pen leave delay"),
    			"pen_pool_delay",
    			new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { PREFERENCES.pen_pool_delay = max(0, val); PREF_SAVE(); })
    		));
    		
    	ds_list_add(pref_global, __txt("Save/Load"));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_auto_save_time", "Autosave delay (-1 to disable)"),
    			"auto_save_time",
    			new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { PREFERENCES.auto_save_time = val; PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_save_layout", "Save layout"),
    			"save_layout",
    			new checkBox(function() /*=>*/ { PREFERENCES.save_layout = !PREFERENCES.save_layout; PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_save_file_minify", "Minify save file"),
    			"save_file_minify",
    			new checkBox(function() /*=>*/ { PREFERENCES.save_file_minify = !PREFERENCES.save_file_minify; PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_save_file_compress", "Compress save file"),
    			"save_compress",
    			new checkBox(function() /*=>*/ { PREFERENCES.save_compress = !PREFERENCES.save_compress; PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_save_backups", "Backup save(s) amount"),
    			"save_backup",
    			new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { PREFERENCES.save_backup = max(0, val);  PREF_SAVE(); })
    		));
    	
    	ds_list_add(pref_global, __txt("Crash"));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_legacy_exception", "Use legacy exception handler"),
    			"use_legacy_exception",
    			new checkBox(function() /*=>*/ { PREFERENCES.use_legacy_exception = !PREFERENCES.use_legacy_exception; PREF_APPLY(); PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_crash_dialog", "Show dialog after crash"),
    			"show_crash_dialog",
    			new checkBox(function() /*=>*/ { PREFERENCES.show_crash_dialog = !PREFERENCES.show_crash_dialog;  PREF_APPLY(); PREF_SAVE(); })
    		));
    		
    	ds_list_add(pref_global, __txt("Misc"));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_clear_temp", "Clear temp file on close"),
    			"clear_temp_on_close",
    			new checkBox(function() /*=>*/ { PREFERENCES.clear_temp_on_close = !PREFERENCES.clear_temp_on_close; PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_enable_test_mode", "Enable developer mode*"),
    			"test_mode",
    			new checkBox(function() /*=>*/ { PREFERENCES.test_mode = !PREFERENCES.test_mode; should_restart = true; PREF_SAVE(); })
    		));
    		
    		if(PREFERENCES.test_mode) {
    			ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    				__txtx("pref_exp_popup_dialog", "[Experimental] Pop-up Dialog"),
    				"multi_window",
    				new checkBox(function() /*=>*/ { PREFERENCES.multi_window = !PREFERENCES.multi_window; PREF_SAVE(); })
    			));
    		}
    	
    	ds_list_add(pref_global, __txt("Paths"));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item(
    			__txtx("pref_directory", "Main directory path*"),
    			new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { PRESIST_PREF.path = txt; json_save_struct(APP_DIRECTORY + "persistPreference.json", PRESIST_PREF); })
    				.setSideButton(button(function() /*=>*/ { 
    					PRESIST_PREF.path = get_directory(struct_try_get(PRESIST_PREF, "path", ""));
    					json_save_struct(APP_DIRECTORY + "persistPreference.json", PRESIST_PREF);
    				}, THEME.button_path_icon)).setFont(f_p2).setEmpty(),
    			
    			function(   ) /*=>*/ { return struct_try_get(PRESIST_PREF, "path", ""); },
    			function(val) /*=>*/ { PRESIST_PREF.path = val; json_save_struct(APP_DIRECTORY + "persistPreference.json", PRESIST_PREF); },
    			APP_DIRECTORY,
    		).setKey("main_dir_path"));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_directory_temp", "Temp directory path*"),
    			"temp_path",
    			new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { PREFERENCES.temp_path = txt; PREF_SAVE(); })
    				.setSideButton(button(function() /*=>*/ { PREFERENCES.temp_path = get_directory(PREFERENCES.temp_path); PREF_SAVE(); }, THEME.button_path_icon))
    				.setFont(f_p2).setEmpty(),
    		));
    	
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_directory_assets", "Assets directory path*"),
    			"path_assets",
    			new folderArrayBox(PREFERENCES.path_assets, function() /*=>*/ { PREF_SAVE(); }).setFont(f_p2),
    		));
    	
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_directory_font", "Font directory path*"),
    			"path_fonts",
    			new folderArrayBox(PREFERENCES.path_fonts, function() /*=>*/ { PREF_SAVE(); }).setFont(f_p2),
    		));
    	
    	ds_list_add(pref_global, __txt("Libraries"));
    	
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_directory_ImageMagick", "ImageMagick path*"),
    			"ImageMagick_path",
    			new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { PREFERENCES.ImageMagick_path = txt; PREF_SAVE(); })
    				.setSideButton(button(function() /*=>*/ { PREFERENCES.ImageMagick_path = get_directory(PREFERENCES.ImageMagick_path); PREF_SAVE(); }, THEME.button_path_icon))
    				.setFont(f_p2).setEmpty(),
    		));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_directory_webp", "Webp path*"),
    			"webp_path",
    			new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { PREFERENCES.webp_path = txt; PREF_SAVE(); })
    				.setSideButton(button(function() /*=>*/ { PREFERENCES.webp_path = get_directory(PREFERENCES.webp_path); PREF_SAVE(); }, THEME.button_path_icon))
    				.setFont(f_p2).setEmpty(),
    		));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_directory_gifski", "Gifski path*"),
    			"gifski_path",
    			new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { PREFERENCES.gifski_path = txt; PREF_SAVE(); })
    				.setSideButton(button(function() /*=>*/ { PREFERENCES.gifski_path = get_directory(PREFERENCES.gifski_path); PREF_SAVE(); }, THEME.button_path_icon))
    				.setFont(f_p2).setEmpty(),
    		));
    		
    		ds_list_add(pref_global, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_directory_FFmpeg", "FFmpeg path*"),
    			"ffmpeg_path",
    			new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { PREFERENCES.gifski_path = txt; PREF_SAVE(); })
    				.setSideButton(button(function() /*=>*/ { PREFERENCES.ffmpeg_path = get_directory(PREFERENCES.ffmpeg_path); PREF_SAVE(); }, THEME.button_path_icon))
    				.setFont(f_p2).setEmpty(),
    		));
    	
    #endregion
    
    #region interface
    	pref_appr = ds_list_create();
    	
    	ds_list_add(pref_appr, __txt("Interface")); /////////////////////////////////////////////////////////////// Interface
    	
    		PREFERENCES._display_scaling = PREFERENCES.display_scaling;
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item(
    			__txtx("pref_gui_scaling", "GUI scaling*"),
    			slider(0.5, 2, 0.01, function(val) /*=>*/ { PREFERENCES._display_scaling = val; should_restart = true; }, 
    			function(   ) /*=>*/ { 
    				PREFERENCES._display_scaling = max(PREFERENCES._display_scaling, 0.5);
    				resetScale(PREFERENCES._display_scaling, true); should_restart = true;
    			}),
    			
    			function(   ) /*=>*/ { return PREFERENCES._display_scaling; },
    			function(val) /*=>*/ {
    				PREFERENCES._display_scaling = val;
    				resetScale(PREFERENCES._display_scaling, true); should_restart = true;
    			},
    			1,
    		).setKey("ui_scale"));
    		
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_ui_frame_rate", "UI frame rate"),
    			"ui_framerate",
    			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { 
    				PREFERENCES.ui_framerate = max(15, round(real(str)));
    				game_set_speed(PREFERENCES.ui_framerate, gamespeed_fps);
    				PREF_SAVE();
    			})
    		));
    		
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_ui_frame_rate", "UI inactive frame rate"),
    			"ui_framerate_non_focus",
    			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { 
    				PREFERENCES.ui_framerate_non_focus = max(1, round(real(str)));
    				game_set_speed(PREFERENCES.ui_framerate_non_focus, gamespeed_fps);
    				PREF_SAVE();
    			})
    		));
    		
    		locals = [];
    		var f = file_find_first(DIRECTORY + "Locale/*", fa_directory);
    		while(f != "") {
    			if(directory_exists(DIRECTORY + "Locale/" + f)) { if(f != "_extend") array_push(locals, f); }
    			f = file_find_next();
    		}
    		file_find_close();
    		
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_interface_language", "Interface Language*"),
    			"local",
    			new scrollBox(locals, function(str) /*=>*/ { 
    				should_restart = true;
    				if(str < 0) return;
    				PREFERENCES.local = locals[str];
    				PREF_SAVE();
    			}, false)
    		));
    		
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_ui_font", "Overwrite UI font") + "*",
    			"font_overwrite",
    			new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { PREFERENCES.font_overwrite = txt; should_restart = true; PREF_SAVE(); })
    				.setSideButton(button(function() /*=>*/ { PREFERENCES.font_overwrite = get_open_filename_pxc("Font files (.ttf, .otf)|*.ttf;*.otf", ""); PREF_SAVE(); }, THEME.button_path_icon))
    				.setFont(f_p2).setEmpty()
    		));
    		
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_windows_control", "Use Windows style window control."),
    			"panel_menu_right_control",
    			new checkBox(function() /*=>*/ { PREFERENCES.panel_menu_right_control = !PREFERENCES.panel_menu_right_control; PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_ui_fix_window_size", "Fix Window size on start"),
    			"window_fix",
    			new checkBox(function() /*=>*/ { 
    				PREFERENCES.window_fix = !PREFERENCES.window_fix;
    				PREF_SAVE();
    			})
    		));
    		
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_ui_fix_width", "Fix width"),
    			"window_fix_width",
    			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { 
    				PREFERENCES.window_fix_width = max(1, round(real(str)));
    				PREF_SAVE();
    			})
    		));
    		
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_ui_fix_height", "Fix height"),
    			"window_fix_height",
    			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { 
    				PREFERENCES.window_fix_height = max(1, round(real(str)));
    				PREF_SAVE();
    			})
    		));
    		
    	ds_list_add(pref_appr, __txt("Splash"));
    		
    		if(IS_PATREON)
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_supporter_icon", "Show supporter icon"),
    			"show_supporter_icon",
    			new checkBox(function() /*=>*/ { PREFERENCES.show_supporter_icon = !PREFERENCES.show_supporter_icon; PREF_SAVE(); })
    		));
    	
    	ds_list_add(pref_appr, __txt("Graph")); //////////////////////////////////////////////////////////////////////// Graph
    	
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_add_node_remember", "Remember add node position"),
    			"add_node_remember",
    			new checkBox(function() /*=>*/ { PREFERENCES.add_node_remember = !PREFERENCES.add_node_remember; })
    		));
    		
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_graph_group_in_tab", "Open group in new tab"),
    			"graph_open_group_in_tab",
    			new checkBox(function() /*=>*/ { PREFERENCES.graph_open_group_in_tab = !PREFERENCES.graph_open_group_in_tab; PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_graph_zoom_smoothing", "Graph zoom smoothing"),
    			"graph_zoom_smoooth",
    			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { PREFERENCES.graph_zoom_smoooth = max(1, round(real(str))); PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("panel_graph_group_require_shift", "Hold Shift to enter group"),
    			"panel_graph_group_require_shift",
    			new checkBox(function() /*=>*/ { PREFERENCES.panel_graph_group_require_shift = !PREFERENCES.panel_graph_group_require_shift; PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_use_alt", "Use ALT for"),
    			"alt_picker",
    			new buttonGroup([ "Pan", "Color Picker" ], function(val) /*=>*/ { PREFERENCES.alt_picker = val; PREF_SAVE(); })
    		));
    		
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item(
    			__txtx("pref_pan_key", "Panning key"),
    			new scrollBox([ "Middle Mouse", "Mouse 4", "Mouse 5" ], function(val) /*=>*/ { PREFERENCES.pan_mouse_key = val + 3; PREF_SAVE(); }),
    			function() /*=>*/ { return PREFERENCES.pan_mouse_key - 3; },
    		).setKey("panning_key"));
    		
    	ds_list_add(pref_appr, __txt("Preview")); ////////////////////////////////////////////////////////////////////// Preview
    	
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_preview_show_real_fps", "Show real fps"),
    			"panel_preview_show_real_fps",
    			new checkBox(function(str) /*=>*/ { PREFERENCES.panel_preview_show_real_fps = !PREFERENCES.panel_preview_show_real_fps; PREF_SAVE(); })
    		));
    		
    	ds_list_add(pref_appr, __txt("Inspector")); //////////////////////////////////////////////////////////////////// Inspector
    	
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_inspector_focus_on_double_click", "Focus on double click"),
    			"inspector_focus_on_double_click",
    			new checkBox(function(str) /*=>*/ { PREFERENCES.inspector_focus_on_double_click = !PREFERENCES.inspector_focus_on_double_click; PREF_SAVE(); })
    		));
    		
    	ds_list_add(pref_appr, __txt("Collection")); /////////////////////////////////////////////////////////////////// Collection
    	
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_collection_preview_speed", "Collection preview speed"),
    			"collection_preview_speed",
    			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { PREFERENCES.collection_preview_speed = max(1, round(real(str))); PREF_SAVE(); })
    		));
    		
    	ds_list_add(pref_appr, __txt("Notification")); ///////////////////////////////////////////////////////////////// Notification
    	
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_warning_notification_time", "Warning notification time"),
    			"notification_time",
    			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { PREFERENCES.notification_time = max(0, round(real(str))); PREF_SAVE(); })
    		));
    		
    	ds_list_add(pref_appr, __txt("Text Area")); //////////////////////////////////////////////////////////////////// Text area
    	
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_widget_autocomplete_delay", "Code Autocomplete delay"),
    			"widget_autocomplete_delay",
    			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { PREFERENCES.widget_autocomplete_delay = round(real(str)); PREF_SAVE(); })
    		));
    	
    	if(IS_PATREON) {
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_widget_textbox_shake", "Textbox shake"),
    			"textbox_shake",
    			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { PREFERENCES.textbox_shake = real(str); PREF_SAVE(); })
    		).patreon());
    		
    		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
    			__txtx("pref_widget_textbox_particles", "Textbox particles"),
    			"textbox_particle",
    			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { PREFERENCES.textbox_particle = round(real(str)); PREF_SAVE(); })
    		).patreon());
    		
    	}
    	
    #endregion
    
    #region node
    	pref_node = ds_list_create();
	
		ds_list_add(pref_node, __txt("Defaults"));
		
			ds_list_add(pref_node, new __Panel_Linear_Setting_Item_Preference(
				__txtx("pref_node_default_depth", "Default surface depth"),
				"node_default_depth",
				new scrollBox(global.SURFACE_FORMAT_NAME, function(val) /*=>*/ { PREFERENCES.node_default_depth = val; PREF_SAVE(); })
			));
			
			ds_list_add(pref_node, new __Panel_Linear_Setting_Item_Preference(
				__txtx("pref_node_default_interpolation", "Default interpolation"),
				"node_default_interpolation",
				new scrollBox(global.SURFACE_INTERPOLATION, function(val) /*=>*/ { PREFERENCES.node_default_interpolation = val; PREF_SAVE(); })
			));
			
			ds_list_add(pref_node, new __Panel_Linear_Setting_Item_Preference(
				__txtx("pref_node_default_oversample", "Default oversample"),
				"node_default_oversample",
				new scrollBox(global.SURFACE_OVERSAMPLE, function(val) /*=>*/ { PREFERENCES.node_default_oversample = val; PREF_SAVE(); })
			));
			
			ds_list_add(pref_node, new __Panel_Linear_Setting_Item_Preference(
				__txtx("pref_node_param_width", "Default param width"),
				"node_param_width",
				new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { PREFERENCES.node_param_width = val; PREF_SAVE(); })
			));
			
		ds_list_add(pref_node, __txt("Display"));
		
			ds_list_add(pref_node, new __Panel_Linear_Setting_Item_Preference(
				__txtx("pref_node_param_show", "Show paramater on new node"),
				"node_param_show",
				new checkBox(function() /*=>*/ { PREFERENCES.node_param_show = !PREFERENCES.node_param_show; PREF_SAVE(); })
			));
			
			ds_list_add(pref_node, new __Panel_Linear_Setting_Item_Preference(
				__txtx("pref_node_3d_preview", "3D Preview resolution"),
				"node_3d_preview_size",
				new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { PREFERENCES.node_3d_preview_size = clamp(val, 16, 1024); PREF_SAVE(); })
			));
		
		ds_list_add(pref_node, __txt("Files"));
		
			ds_list_add(pref_node, new __Panel_Linear_Setting_Item_Preference(
				__txtx("pref_file_watcher_delay", "File watcher delay (s)"),
				"file_watcher_delay",
				new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { PREFERENCES.file_watcher_delay = val; PREF_SAVE(); })
			));
		
    #endregion
    
    #region theme
    
    	////- Themes
    	
    	themes = [];
    	themeCurrent = noone;
    	
    	var f = file_find_first(DIRECTORY + "Themes/*", fa_directory);
    	while(f != "") {
    		var _file = f;
    		var _path = $"{DIRECTORY}Themes/{f}";
    		f = file_find_next();
    		
    		if(!directory_exists(_path)) continue;
    		
    		var _metaPath = $"{_path}/meta.json";
    		
    		if(!file_exists_empty(_metaPath)) {
    			var _item = new scrollItem(_file, THEME.circle, 0, COLORS._main_accent)
    							.setTooltip("Theme made for earlier version.");
    			array_push(themes, _item);
    			continue;
    		} 
    		
    		var _meta = json_load_struct(_metaPath);
    		    _meta.file = _file;
    		    
    		var _item = new scrollItem(_meta.name, _meta.version >= VERSION? noone : THEME.circle, 0, COLORS._main_accent);
    		    _item.data = _meta;
    		
    		if(PREFERENCES.theme == _file) themeCurrent = _meta;
    		
    		if(_meta.version < VERSION) _item.tooltip = "Theme made for earlier version.";
    		array_push(themes, _item);
    	}
    	file_find_close();
    	
    	sb_theme = new scrollBox(themes, function(index) { 
    		var dat = themes[index].data;
    		var thm = dat.file;
    		if(PREFERENCES.theme == thm) return;
    		
    		themeCurrent = dat;
    		PREFERENCES.theme = thm;
    		PREF_SAVE();
    		
    		loadGraphic(thm);
    		loadColor(thm);
    		loadFonts();
    	}, false);
    	sb_theme.font  = f_p2;
    	sb_theme.align = fa_left;
    	
    	tb_override = new textBox(TEXTBOX_INPUT.text, function(val) /*=>*/ { PREFERENCES.theme_override = val; loadColor(PREFERENCES.theme); PREF_SAVE(); })
    	
    	sp_theme = new scrollPane(panel_width, panel_height - ui(40), function(_y, _m) {
    		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
    		
    		var _hover = sp_theme.hover;
    		var _focus = sp_theme.active;
    		var _rx    = x + sp_theme.x;
    		var _ry    = y + sp_theme.y;
    		
    		var ww     = sp_theme.surface_w;
    		var hh     = sp_theme.surface_h;
    		
    		var hh  = ui(8);
    		    _y += ui(8);
    		
    		var _h = ui(24);
    		if(buttonInstant(THEME.button_hide_fill, ww - _h, _y, _h, _h, _m, _hover, _focus, __txt("Reset colors"), THEME.refresh_16) == 2) {
    			var path = $"{DIRECTORY}Themes/{PREFERENCES.theme}/{PREFERENCES.theme_override}.json";
    			if(file_exists_empty(path)) file_delete(path);
    			loadColor(PREFERENCES.theme);
    		}
    		
    		var _wdw  = ui(128);
    		var _wpar = new widgetParam(ww - _h - ui(4) - _wdw, _y, _wdw, _h, 0, 0, _m, _rx, _ry)
    							.setFont(f_p3)
    							.setFocusHover(_focus, _hover);
    		
    		var thName = themeCurrent == noone? PREFERENCES.theme : themeCurrent.name;
    		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
    		draw_text_add(ui(8), _y + _h / 2, __txt("Theme"));
    		sb_theme.drawParam(_wpar.setData(thName));
    		_y += _h + ui(8);
    		hh += _h + ui(8);
    		
    		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
    		draw_text_add(ui(8), _y + _h / 2, __txt("Variant"));
    		tb_override.drawParam(_wpar.setY(_y).setData(PREFERENCES.theme_override));
    		_y += _h + ui(8 + 4);
    		hh += _h + ui(8 + 4);
    		
    		// Font override
    		
    		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
    		draw_text_add(ui(8), _y + _h / 2, __txt("Font Override"));
    		
    		var _ovr = PREFERENCES.font_overwrite == ""? "None" : filename_name_only(PREFERENCES.font_overwrite);
    		draw_set_text(f_p3, fa_right, fa_center, COLORS._main_text_sub);
    		draw_text_add(ww - _h - ui(4), _y + _h / 2, _ovr);
    		_y += _h + ui(8 + 4);
    		hh += _h + ui(8 + 4);
    		
    		// Metadata box
    		
    		var _mh = themeCurrent == noone? ui(16) : ui(8 + 4 + 20 * 4);
    		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, 0, _y, ww, _mh, COLORS._main_icon_light);
    		
    		if(themeCurrent) {
    			var _yy = _y + ui(8);
    			draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
    			draw_text_add(ui(16), _yy, __txt("Name"));
    			
    			draw_set_text(f_p3, fa_right, fa_top, COLORS._main_text);
    			draw_text_add(ww - ui(16), _yy, themeCurrent.name);
    			
    			_yy += ui(20);
    			draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
    			draw_text_add(ui(16), _yy, __txt("Author"));
    			
    			draw_set_text(f_p3, fa_right, fa_top, COLORS._main_text);
    			draw_text_add(ww - ui(16), _yy, themeCurrent.author);
    			
    			_yy += ui(20);
    			draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
    			draw_text_add(ui(16), _yy, __txt("Version"));
    			
    			draw_set_text(f_p3, fa_right, fa_top, COLORS._main_text);
    			draw_text_add(ww - ui(16), _yy, themeCurrent.version);
    			
    			_yy += ui(20);
    			draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text_sub);
    			draw_text_add(ui(16), _yy, __txt("Dependency"));
    			
    			var _d = struct_try_get(themeCurrent, "dependency", "none");
    			draw_set_text(f_p3, fa_right, fa_top, COLORS._main_text);
    			draw_text_add(ww - ui(16), _yy, _d);
    		}
    		
    		_y += _mh + ui(8 + 4);
    		hh += _mh + ui(8 + 4);
    		
    		return hh;
    	});
    	
    	////- Colors
    	
    	color_selector_key = noone;
    	
    	color_selector_edit = noone;
    	tb_color_key_edit   = new textBox(TEXTBOX_INPUT.text, function(t) /*=>*/ {
    		if(color_selector_edit == noone) return;
    		
    		var _v = _loadColorStringParse(t);
    		COLORS_KEYS.define[$ color_selector_edit] = _v;
    		COLORS[$ color_selector_edit] = _loadColorString(_v);
    		overrideColor(color_selector_edit, _v);
    		
    		color_selector_edit = noone;
    	}).setFont(f_p3);
    	
    	sp_theme_colors = new scrollPane(panel_width, panel_height - ui(40), function(_y, _m) {
    		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
    		var ww   = sp_theme_colors.surface_w;
    		var hh	 = 0;
    		
    		var _hover = sp_theme_colors.hover;
    		var _focus = sp_theme_colors.active;
    		
    		var x1	 = sp_theme_colors.surface_w;
    		var yy	 = _y + ui(8);
    		var padx = ui(0);
    		var pady = ui(6);
    		var th   = line_get_height(font);
    		var ind	 = 0;
    		
    		var cp = ui(0)
    		var cw = ui(100);
    		var ch = th - cp * 2;
    		var cx = x1 - cw - padx - ui(24 + 8);
    		var category = "", cat;
    		
    		var group_labels = [];
    		var sectH = ui(24);
    		var sect  = [];
    		var psect = "";
    		
    		var _search_text = string_lower(search_text);
    		
    		for( var i = 0, n = array_length(global.palette_keys); i < n; i++ ) {
    			var key = global.palette_keys[i];
    			var val = CDEF[$ key];
    			if(_search_text != "" && string_pos(_search_text, string_lower(key)) == 0) continue;
    			
    			var cat = "global";
    			
    			if(cat != category) {
    				category = cat;
    				
    				var _sect = string_title(category);
    				var _coll = struct_try_get(collapsed, cat, 0);
    				
    				array_push(sect, [ _sect, sp_theme_colors, hh + ui(12) ]);
    				array_push(group_labels, { y: yy, text: _sect, key: cat });
    				
    				if(yy >= 0 && section_current == "") section_current = psect;
    				psect = _sect;
    				
    				yy += sectH + ui(!_coll * 4 + 4);
    				hh += sectH + ui(!_coll * 4 + 4);
    				ind = 0;
    			}
    			
    			if(struct_try_get(collapsed, cat, 0)) continue;
    			
    			if(ind % 2) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, padx, yy - pady, ww - padx * 2, th + pady * 2, COLORS.dialog_preference_prop_bg, .75);
    					
    			var keyStr = string_title(key);
    			
    			draw_set_text(font, fa_left, fa_center, COLORS._main_text);
    			draw_text_add(ui(32), yy + th / 2, keyStr);
    			
    			var b = buttonInstant(THEME.button_def, cx, yy + cp, cw, ch, _m, _hover, _focus);
    			draw_sprite_stretched_ext(THEME.palette_mask, 1, cx + ui(2), yy + ui(2), cw - ui(4), ch - ui(4), val, 1);
    			
    			if(b) sp_theme_colors.hover_content = true;
    			if(b == 2) {
    				color_selector_key = key;
    				
    				var clrSelect = dialogCall(o_dialog_color_selector)
    									.setDefault(val)
    									.setApply(function(color) /*=>*/ { CDEF[$ color_selector_key] = color; overrideColor(color_selector_key, color); refreshThemePalette(); });
    			}
    			
    			var _bs = ui(24);
    			var _bx = x1 - padx - ui(4) - _bs;
    			var _by = yy + th / 2 - _bs / 2;
    				
    			if(struct_has(COLORS_OVERRIDE, key)) {
    				if(buttonInstant(THEME.button_hide_fill, _bx, _by, _bs, _bs, _m, _hover, _focus, __txt("Reset"), THEME.refresh_16) == 2) {
    					CDEF[$ key] = color_from_rgb(COLORS_DEF.colors[$ key]);
    					overrideColorRemove(key);
    					refreshThemePalette();
    				}
    			} else
    				draw_sprite_ext(THEME.refresh_16, 0, _bx + _bs / 2, _by + _bs / 2, 1, 1, 0, COLORS._main_icon_dark);
    			
    			yy += th + pady * 2;
    			hh += th + pady * 2;
    			ind++;
    		}
    		
    		for( var i = 0, n = array_length(COLOR_KEYS); i < n; i++ ) {
    			var key = COLOR_KEYS[i];
    			var val = COLORS[$ key];
    			
    			if(_search_text != "" && string_pos(_search_text, string_lower(key)) == 0) continue;
    			if(is_array(val)) continue;
    			
    			var spl = string_splice(key, "_");
    			var cat = spl[0] == ""? spl[1] : spl[0];
    			
    			if(cat != category) {
    				category = cat;
    				var _sect = string_title(category);
    				var _coll = struct_try_get(collapsed, cat, 0);
    				
    				array_push(sect, [ _sect, sp_theme_colors, hh + ui(12) ]);
    				array_push(group_labels, { y: yy, text: _sect, key: cat });
    				
    				if(yy >= 0 && section_current == "") section_current = psect;
    				psect = _sect;
    				
    				yy += sectH + ui(!_coll * 4 + 4);
    				hh += sectH + ui(!_coll * 4 + 4);
    				ind = 0;
    			}
    		
    			if(struct_try_get(collapsed, cat, 0)) continue;
    			
    			if(ind % 2) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, padx, yy - pady, ww - padx * 2, th + pady * 2, COLORS.dialog_preference_prop_bg, .75);
    					
    			var keyStr = string_replace_all(key, "_", " ");
    			    keyStr = string_replace(keyStr, cat + " ", "");
    			    keyStr = string_title(keyStr);
    			
    			var cy = yy + th / 2;
    			
    			draw_set_text(font, fa_left, fa_center, COLORS._main_text);
    			draw_text_add(ui(32), cy, keyStr);
    			
    			var _dx1 = cx - ui(4);
    			var _dx0 = _dx1 - ui(16);
    			var _dy0 = cy - ui(12);
    			var _dy1 = cy + ui(12);
    			
    			if(struct_has(COLORS_KEYS.define, key)) {
    				var _def_key = COLORS_KEYS.define[$ key];
    				
    				draw_set_text(f_p3, fa_right, fa_center, COLORS._main_text_sub);
    				draw_text_add(cx - ui(8), cy, _def_key);
    				
    				_dx0 = _dx1 - ui(8) - string_width(_def_key);
    			}
    			
    			if(color_selector_edit == key) {
    				var _tbw = ui(128)
    				var _tbh = ui(24)
    				tb_color_key_edit.setFocusHover(_focus, _hover);
    				tb_color_key_edit.draw(_dx1 - _tbw, cy - _tbh / 2, _tbw, _tbh, COLORS_KEYS.define[$ key], _m)
    				
    			} else {
    				if(pHOVER && point_in_rectangle(_m[0], _m[1], _dx0, _dy0, _dx1, _dy1)) {
    					draw_sprite_stretched_ext(THEME.button_hide, 1, _dx0, _dy0, _dx1 - _dx0, _dy1 - _dy0);
    					if(mouse_press(mb_left, _focus)) {
    						color_selector_edit = key;
    						tb_color_key_edit.activate(COLORS_KEYS.define[$ key]);
    					}
    				}
    			}
    			
    			var b = buttonInstant(THEME.button_def, cx, yy + cp, cw, ch, _m, _hover, _focus);
    			draw_sprite_stretched_ext(THEME.palette_mask, 1, cx + ui(2), yy + ui(2), cw - ui(4), ch - ui(4), val, 1);
    			
    			if(b) sp_theme_colors.hover_content = true;
    			if(b == 2) {
    				color_selector_key = key;
    				
    				var clrSelect = dialogCall(o_dialog_color_selector)
    									.setDefault(val)
    									.setApply(function(color) /*=>*/ { 
    										COLORS_KEYS.define[$ color_selector_key] = color;
    										COLORS[$ color_selector_key] = color; 
    										overrideColor(color_selector_key, color); 
    									});
    			}
    			
    			var _bs = ui(24);
    			var _bx = x1 - padx - ui(4) - _bs;
    			var _by = cy - _bs / 2;
    				
    			if(struct_has(COLORS_OVERRIDE, key)) {
    				if(buttonInstant(THEME.button_hide_fill, _bx, _by, _bs, _bs, _m, _hover, _focus, __txt("Reset"), THEME.refresh_16) == 2) {
    					var _v = COLORS_DEF.define[$ key];
    					
    					COLORS_KEYS.define[$ key] = _v;
    					COLORS[$ key] = _loadColorString(_v);
    					overrideColorRemove(key);
    				}
    			} else
    				draw_sprite_ext(THEME.refresh_16, 0, _bx + _bs / 2, _by + _bs / 2, 1, 1, 0, COLORS._main_icon_dark);
    			
    			yy += th + pady * 2;
    			hh += th + pady * 2;
    			ind++;
    		}
    		
    		#region ------------ section label ------------
    			var len = array_length(group_labels);
    			if(len && group_labels[0].y < 0) {
    				gpu_set_blendmode(bm_subtract);
    				draw_set_color(c_white);
    				draw_rectangle(0, 0, ww, sectH + ui(8 + 4), false);
    				gpu_set_blendmode(bm_normal);
    			}
    			
    			var _cAll = 0;
    			
    			for( var i = 0; i < len; i++ ) {
    				var lb = group_labels[i];
    				var _name = lb.text;
    				var _key  = lb.key;
    				var _coll = struct_try_get(collapsed, _key, 0);
    				
    				var _yy = max(lb.y, i == len - 1? ui(8) : min(ui(8), group_labels[i + 1].y - ui(32)));
    				var _hv = _hover && point_in_rectangle(_m[0], _m[1], 0, _yy, ww, _yy + sectH);
    				var _tc = CDEF.main_ltgrey;
    				
    				BLEND_OVERRIDE
                	draw_sprite_stretched_ext(THEME.box_r5_clr, 0, padx, _yy, ww - padx * 2, sectH, _hv? COLORS.panel_inspector_group_hover : COLORS.panel_inspector_group_bg, 1);
                	
    				if(_hv && _focus) {
                    	if(DOUBLE_CLICK) {
                    		_cAll = _coll? -1 : 1;
                    		
                    	} else if(mouse_press(mb_left)) {
                        	if(_coll) struct_set(collapsed, _key, 0);
                        	else      struct_set(collapsed, _key, 1);
                        }
                    }
                        
    				BLEND_NORMAL
    				
    				draw_sprite_ui(THEME.arrow, _coll? 0 : 3, padx + ui(16), _yy + sectH / 2, 1, 1, 0, _tc, 1);    
    				
    				draw_set_text(f_p2, fa_left, fa_center, _tc);
    				draw_text_add(padx + ui(28), _yy + sectH / 2, _name);
    			}
    			
    				 if(_cAll ==  1) { for( var i = 0; i < len; i++ ) struct_set(collapsed, group_labels[i].key, 0); } 
    			else if(_cAll == -1) { for( var i = 0; i < len; i++ ) struct_set(collapsed, group_labels[i].key, 1); }
    			
    			// sections[page_current] = sect;
    		#endregion
    		
    		return hh + ui(16);
    	});
    	
    	function overrideColor(key, val) {
    		var path = $"{DIRECTORY}Themes/{PREFERENCES.theme}/{PREFERENCES.theme_override}.json";
    		var json = file_exists_empty(path)? json_load_struct(path) : {};
    		
    		json[$ key] = val;
    		COLORS_OVERRIDE[$ key] = val;
    		
    		json_save_struct(path, json, true);
    	}
    	
    	function overrideColorRemove(key) {
    		var path = $"{DIRECTORY}Themes/{PREFERENCES.theme}/{PREFERENCES.theme_override}.json";
    		var json = file_exists_empty(path)? json_load_struct(path) : {};
    		
    		struct_remove(json, key);
    		struct_remove(COLORS_OVERRIDE, key);
    		
    		json_save_struct(path, json, true);
    	}
    	
    	////- Sprites
    	
    	sprKeys = variable_struct_get_names(THEME);
    	array_sort(sprKeys, true);
    		
    	sp_theme_sprites = new scrollPane(panel_width, panel_height - ui(40), function(_y, _m) {
    		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
    		
    		var _hover = sp_theme_sprites.hover;
    		var _focus = sp_theme_sprites.active;
    		var _rx    = sp_theme_sprites.x;
    		var _ry    = sp_theme_sprites.y;
    		
    		var ww     = sp_theme_sprites.surface_w;
    		var hh     = sp_theme_sprites.surface_h;
    		
    		var _h   = ui(8);
    		    _y  += ui(8);
    		var hg   = ui(24);
    		var ind  = 0;
    		var padx = ui(0);
    		var pady = ui(4);
    		
    		var _search_text = string_lower(search_text);
    		
    		for( var i = 0, n = array_length(sprKeys); i < n; i++ ) {
    			var _key = sprKeys[i];
    			var _spr = THEME[$ _key];
    			if(_search_text != "" && string_pos(_search_text, string_lower(_key)) == 0) continue;
    			
    			var yc = _y + hg / 2;
    			if(ind % 2) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, padx, _y - pady, ww - padx * 2, hg + pady * 2, COLORS.dialog_preference_prop_bg, .75);
    			
    			if(_y > -hg && _y < hh) {
    				draw_set_text(font, fa_left, fa_center, COLORS._main_text);
    				draw_text_add(ui(32), yc, _key);
    				
    				if(sprite_exists(_spr)) {
    					var _sw = sprite_get_width(_spr);
    					var _sh = sprite_get_height(_spr);
    					
    					var _ss = min(hg / _sh, ui(128) / _sw);
    					
    					var _ox = (sprite_get_xoffset(_spr) - _sw / 2) * _ss;
    					var _oy = (sprite_get_yoffset(_spr) - _sh / 2) * _ss;
    					
    					var _sx = ww / 2 + _ox;
    					var _sy = yc     + _oy;
    					
    					draw_sprite_ext(_spr, 0, _sx, _sy, _ss, _ss);
    					
    					draw_set_text(font, fa_left, fa_center, COLORS._main_text_sub);
    					draw_text_add(ww / 2 + ui(96), yc, $"{_sw}x{_sh} [{sprite_get_number(_spr)}]");
    				}
    			}
    			
    			ind++;
    			_y += hg + pady * 2;
    			_h += hg + pady * 2;
    		}
    		
    		return _h;
    	});
    	
    	////- Fonts
    	
    	fontKeys = variable_struct_get_names(FONT_LIST);
    	array_sort(fontKeys, true);
    	
    	array_push_to_back(fontKeys, "code");
    	array_push_to_back(fontKeys, "f_sdf");
    	array_push_to_back(fontKeys, "f_sdf_medium");
    	
    	sp_theme_fonts = new scrollPane(panel_width, panel_height - ui(40), function(_y, _m) {
    		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
    		
    		var _hover = sp_theme_fonts.hover;
    		var _focus = sp_theme_fonts.active;
    		var _rx    = x + sp_theme_fonts.x;
    		var _ry    = y + sp_theme_fonts.y;
    		
    		var ww     = sp_theme_fonts.surface_w;
    		var hh     = sp_theme_fonts.surface_h;
    		
    		var _h   = ui(8);
    		    _y  += ui(8);
    		var hg   = ui(24);
    		var ind  = 0;
    		var padx = ui(0);
    		var pady = ui(4);
    		
    		var _search_text = string_lower(search_text);
    		
    		for( var i = 0, n = array_length(fontKeys); i < n; i++ ) {
    			var _key = fontKeys[i];
    			var _fnt = FONT_LIST[$ _key];
    			var _font = _fnt.font;
    			if(_search_text != "" && string_pos(_search_text, string_lower(_key)) == 0) continue;
    			
    			var hgg = font_exists(_font)? line_get_height(_font) : hg;
    			
    			var yc = _y + hgg / 2;
    			if(ind % 2) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, padx, _y - pady, ww - padx * 2, hgg + pady * 2, COLORS.dialog_preference_prop_bg, .75);
    			
    			if(_y > -hgg && _y < hh) {
    				draw_set_text(font, fa_left, fa_center, COLORS._main_text);
    				draw_text_add(ui(32), yc, _key);
    				
    				if(font_exists(_font)) {
    					var _name = font_get_fontname(_font);
    					    _name = filename_name_only(_name);
    					
    					draw_set_text(_font, fa_right, fa_center, COLORS._main_text);
    					draw_text_add(ww - ui(16), yc, _name);
    				}
    			}
    			
    			ind++;
    			_y += hgg + pady * 2;
    			_h += hgg + pady * 2;
    		}
    		
    		return _h;
    	});
    	
    	////- Resources tab
    	
    	theme_page      = 0;
    	theme_pages     = [
    	    sp_theme_colors,
            sp_theme_sprites,
            sp_theme_fonts,
	    ];
    	theme_page_name = [
    		$"Colors [{array_length(global.palette_keys) + array_length(COLOR_KEYS)}]", 
    		$"Sprites [{array_length(sprKeys)}]", 
    		$"Fonts [{array_length(fontKeys)}]", 
    	];
    	tab_resources = new buttonGroup(theme_page_name, function(i) /*=>*/ { theme_page = i })
    						.setButton([ THEME.button_hide_left, THEME.button_hide_middle, THEME.button_hide_right ])
       						.setFont(f_p2, COLORS._main_text_sub);
    	
    #endregion
    
    #region hotkey
    	hk_editing    = noone;
    	hk_modifiers  = MOD_KEY.none;
    	hotkeyContext = [];
    	hotkeyArray   = [];
    	
    	hotkey_focus           = noone;
    	hotkey_focus_highlight = noone;
    	hotkey_focus_high_bg   = 0;
    	hotkey_focus_index     = 0;
    	
    	keyboards_display = new KeyboardDisplay();
    	
    	for(var j = 0; j < ds_list_size(HOTKEY_CONTEXT); j++) {
    		var ctx  = HOTKEY_CONTEXT[| j];
    		var _lst = [];
    		
    		var ll = HOTKEYS[? ctx];
    		for(var i = 0; i < ds_list_size(ll); i++)
    			array_push(_lst, ll[| i]);
    		
    		array_sort(_lst, function(s1, s2) /*=>*/ {return string_compare(s1.name, s2.name)});
    		array_push(hotkeyContext, { context: ctx, list: _lst });
    		
    		var _title = ctx == ""? "Global" : ctx;
    		    _title = string_replace_all(_title, "_", " ");
    		array_push(hotkeyArray, _title);
    	}
    	
    	var keys = struct_get_names(HOTKEYS_CUSTOM);
    	for( var i = 0, n = array_length(keys); i < n; i++ ) {
    		var ctx = keys[i];
    		
    		var hotkey = HOTKEYS_CUSTOM[$ ctx];
    		var hks    = struct_get_names(hotkey);
    		var _lst   = [];
    		
    		for (var j = 0, m = array_length(hks); j < m; j++) {
    			var _n = hks[j];
    			var _k = hotkey[$ _n];
    			
    			_k.context = ctx;
    			_k.name    = _n;
    			
    			array_push(_lst, _k);
    		}
    		
    		array_sort(_lst, function(s1, s2) /*=>*/ {return string_compare(s1.name, s2.name)});
    		array_push(hotkeyContext, { context: ctx, list: _lst });
    		array_push(hotkeyArray, $"   {ctx}");
    	}
    	
    	hk_page   = 0;
    	hk_scroll = new scrollBox(hotkeyArray, function(val) /*=>*/ { hk_page = val; sp_hotkey.scroll_y_to = 0; });
    	hk_scroll.align = fa_left;
    	
    	sp_hotkey = new scrollPane(panel_width, hotkey_height, function(_y, _m) {
    		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
    		draw_set_text(f_p2, fa_left, fa_top);
    		
    		var padd	  = ui(6);
    		var hh		  = 0;
    		var currGroup = noone;
    		
    		var _ww       = sp_hotkey.surface_w;
    		var key_x1    = _ww - ui(32);
    		var yy        = _y + ui(8);
    		
    		var ind       = 0;
    		var sect      = [];
    		var psect     = "";
    		var th        = line_get_height();
    		var _hov      = pHOVER && sp_hotkey.hover;
    		var modified  = false;
    		
    		var _ctxObj = hotkeyContext[hk_page];
    		var _cntx   = _ctxObj.context;
    		var _list   = _ctxObj.list;
    		var _yy     = yy + hh;
    		
    		var _search = string_lower(search_text);
    		
    		for (var j = 0, m = array_length(_list); j < m; j++) {
    			
    			var key  = _list[j];
    			var name = __txt(key.name);
    			var dk   = key_get_name(key.key, key.modi);
    			
    			if(_search != "" && string_pos(_search, string_lower(name)) == 0
    			                 && string_pos(_search, string_lower(dk))   == 0)
    				continue;
    			
    			var pkey  = key.key;
    			var modi  = key.modi;
    			var _yy   = yy + hh;
    			var _lb_y = _yy;
    			
    			if(hotkey_focus == key) sp_hotkey.scroll_y_to = -hh;
    			
    			if(ind++ % 2 == 0)				  draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, _yy - padd, _ww, th + padd * 2, COLORS.dialog_preference_prop_bg, 1);
    			if(hotkey_focus_highlight == key) draw_sprite_stretched_add(THEME.ui_panel,    0, 0, _yy - padd, _ww, th + padd * 2, COLORS._main_accent, min(1, hotkey_focus_high_bg) * .5);
    			
    			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
    			draw_text_add(ui(24), _lb_y, name);
    			
    			var kw = string_width(dk);
    			
    			var tx = key_x1 - ui(24);
    			var bx = tx - kw - ui(8);
    			var by = _yy - ui(3);
    			var bw = kw + ui(16);
    			var bh = th + ui(6);
    			var cc = c_white;
    			
    			if(hk_editing == key) {
    				draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bw, bh, COLORS._main_accent);
    				cc = COLORS._main_text_accent;
    				
    			} else {
    				if(_hov && point_in_rectangle(_m[0], _m[1], _ww / 2, by, bx + bw, by + bh)) {
    					draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bw, bh, CDEF.main_ltgrey);
    					sp_hotkey.hover_content = true;
    					cc = CDEF.main_white;
    					
    					if(mouse_press(mb_left, pFOCUS)) {
    						hk_editing        = key;
    						keyboard_lastchar = pkey;
    					}
    					
    				} else {
    					// draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bw, bh, CDEF.main_dkgrey, 1);
    					cc = CDEF.main_ltgrey;
    				}
    			}
    			
    			draw_set_text(f_p2, fa_right, fa_top, cc);
    			draw_text_add(tx, _lb_y, dk);
    			
    			if(key.key != key.dKey || key.modi != key.dModi) {
    				modified = true;
    				var bx   = _ww - ui(32);
    				var by   = _yy + th / 2 - ui(12);
    				var b    = buttonInstant(THEME.button_hide_fill, bx, by, ui(24), ui(24), _m, _hov, pFOCUS, __txt("Reset"), THEME.refresh_16);
    				
    				if(b) sp_hotkey.hover_content = true;
    				if(b == 2) {
    					key.key  = key.dKey;
    					key.modi = key.dModi;
    					
    					PREF_SAVE();
    				}
    			}
    			
    			hh += th + padd * 2;
    		}
    		
    		hotkey_focus         = noone;
    		hotkey_focus_high_bg = lerp_linear(hotkey_focus_high_bg, 0, DELTA_TIME);
    		if(hotkey_focus_high_bg == 0) hotkey_focus_highlight = noone;
    		
    		if(hk_editing != noone) hotkey_editing(hk_editing);
    		
    		return hh + ui(32);
    	})
    #endregion
    
    #region scrollpane
    	current_list = pref_global;
    	
    	sp_pref = new scrollPane(panel_width, panel_height, function(_y, _m) {
    		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
    		var ww   = sp_pref.surface_w;
    		var hh	 = 0;
    		var th	 = line_get_height(font, 6);
    		var x1	 = sp_pref.surface_w;
    		var yy	 = _y + ui(8);
    		var padx = ui(8);
    		var pady = ui(6);
    		var ind	 = 0;
    		var rx   = x + sp_pref.x;
    		var ry   = y + sp_pref.y;
    		
    		var _search_text = string_lower(search_text);
    		for(var i = 0; i < ds_list_size(current_list); i++) {
    			var _pref = current_list[| i];
    			if(is_string(_pref)) continue;
    			if(search_text != "" && string_pos(_search_text, string_lower(_pref.name)) == 0) continue;
    			
    			_pref.editWidget.register(sp_pref);
    		}
    		
    		var group_labels = [];
    		var sectH = ui(24);
    		var sect  = [];
    		var psect = "";
    		
    		for(var i = 0; i < ds_list_size(current_list); i++) {
    			var _pref = current_list[| i];
    			
    			if(is_string(_pref)) {
    				var _coll = struct_try_get(collapsed, _pref, 0);
    				
    				array_push(sect, [ _pref, sp_pref, hh + ui(12) ]);
    				array_push(group_labels, { y: yy, text: _pref, key: _pref });
    				
    				if(yy >= 0 && section_current == "") section_current = psect;
    				psect = _pref;
    				
    				yy += sectH + ui(!_coll * 4 + 4);
    				hh += sectH + ui(!_coll * 4 + 4);
    				ind = 0;
    				continue;
    			}
    			
    			if(struct_try_get(collapsed, psect, 0)) continue;
    			
    			var name = _pref.name;
    			var data = _pref.data();
    			
    			if(search_text != "" && string_pos(_search_text, string_lower(name)) == 0) continue;
    			
    			if(ind % 2) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, padx, yy - pady, ww - padx * 2, max(_pref.editWidget.h, th) + pady * 2, COLORS.dialog_preference_prop_bg, .75);
    			
    			if(goto_item == _pref) {
    				if(goto_item_highlight == 2) sp_pref.setScroll(-hh);
    				if(goto_item_highlight == 0) goto_item = noone;
    				
    				draw_sprite_stretched_add(THEME.ui_panel_bg, 0, padx, yy - pady, ww - padx * 2, max(_pref.editWidget.h, th) + pady * 2, COLORS._main_accent, min(1, goto_item_highlight) * 0.5);
    			}
    				
    			draw_set_text(font, fa_left, fa_center, COLORS._main_text);
    			draw_text_add(padx + ui(24), yy + th / 2, name);
    			
    			if(_pref.is_patreon) {
    				var spr_x = padx + ui(20);
    				var spr_y = yy + ui(4);
    				
    				BLEND_SUBTRACT
    				gpu_set_colorwriteenable(0, 0, 0, 1);
    				draw_sprite_ext(THEME.patreon_supporter, 0, spr_x, spr_y, -1, 1, 0, c_white, 1);
    				gpu_set_colorwriteenable(1, 1, 1, 1);
    				BLEND_NORMAL
    			
    				draw_sprite_ext(THEME.patreon_supporter, 1, spr_x, spr_y, -1, 1, 0, COLORS._main_accent, 1);
    			}
    			
    			_pref.editWidget.setFocusHover(pFOCUS, pHOVER && sp_pref.hover); 
    			
    			var widget_w = ui(260);
    			var widget_h = th;
    			
    				 if(is_instanceof(_pref.editWidget, textBox))         widget_w = _pref.editWidget.input == TEXTBOX_INPUT.text? ui(400) : widget_w;
    			else if(is_instanceof(_pref.editWidget, folderArrayBox))  widget_w = ui(400);
    			
    			var widget_x = x1 - padx - ui(4) - widget_w;
    			var widget_y = yy;
    			
    			if(_pref.getDefault != noone)
    				widget_w -= ui(32 + 8);
    				
    			var params  = new widgetParam(widget_x, widget_y, widget_w, widget_h, data, {}, _m, rx, ry);
    			params.s    = th;
    			params.font = font;
    			
    			if(instanceof(_pref.editWidget) == "checkBox") params.halign = fa_center;
    			var wdh = _pref.editWidget.drawParam(params) ?? 0;
    			if(_pref.editWidget.inBBOX(_m)) sp_pref.hover_content = true;
    			
    			if(_pref.getDefault != noone) {
    				var _defVal = is_method(_pref.getDefault)? _pref.getDefault() : _pref.getDefault;
    				var _bs = ui(32);
    				var _bx = x1 - padx - ui(4) - _bs;
    				var _by = yy + wdh / 2 - _bs / 2;
    					
    				if(isEqual(data, _defVal))
    					draw_sprite_ext(THEME.refresh_16, 0, _bx + _bs / 2, _by + _bs / 2, 1, 1, 0, COLORS._main_icon_dark);
    				else {
    					if(buttonInstant(THEME.button_hide_fill, _bx, _by, _bs, _bs, _m, pHOVER, pFOCUS && sp_pref.hover, __txt("Reset"), THEME.refresh_16) == 2)
    						_pref.onEdit(_defVal);
    				}
    			}
    				
    			yy += wdh + pady + ui(6);
    			hh += wdh + pady + ui(6);
    			ind++;
    		}
    		
    		#region section label
    			var len = array_length(group_labels);
    			if(len && group_labels[0].y < 0) {
    				gpu_set_blendmode(bm_subtract);
    				draw_set_color(c_white);
    				draw_rectangle(0, 0, ww, sectH + ui(8 + 4), false);
    				gpu_set_blendmode(bm_normal);
    			}
    			
    			var _cAll = 0;
    			
    			for( var i = 0; i < len; i++ ) {
    				var lb = group_labels[i];
    				var _name = lb.text;
    				var _key  = lb.key;
    				var _coll = struct_try_get(collapsed, _key, 0);
    				
    				var _yy = max(lb.y, i == len - 1? ui(8) : min(ui(8), group_labels[i + 1].y - ui(32)));
    				var _hv = pHOVER && point_in_rectangle(_m[0], _m[1], 0, _yy, ww, _yy + sectH);
    				var _tc = CDEF.main_ltgrey;
    				
    				BLEND_OVERRIDE
                	draw_sprite_stretched_ext(THEME.box_r5_clr, 0, padx, _yy, ww - padx * 2, sectH, _hv? COLORS.panel_inspector_group_hover : COLORS.panel_inspector_group_bg, 1);
                	
    				if(_hv && pFOCUS) {
                    	if(DOUBLE_CLICK) {
                    		_cAll = _coll? -1 : 1;
                    		
                    	} else if(mouse_press(mb_left)) {
                        	if(_coll) struct_set(collapsed, _key, 0);
                        	else      struct_set(collapsed, _key, 1);
                        }
                    }
                        
    				BLEND_NORMAL
    				
    				draw_sprite_ui(THEME.arrow, _coll? 0 : 3, padx + ui(16), _yy + sectH / 2, 1, 1, 0, _tc, 1);    
    				
    				draw_set_text(f_p2, fa_left, fa_center, _tc);
    				draw_text_add(padx + ui(28), _yy + sectH / 2, _name);
    			}
    			
    				 if(_cAll ==  1) { for( var i = 0; i < len; i++ ) struct_set(collapsed, group_labels[i].key, 0); } 
    			else if(_cAll == -1) { for( var i = 0; i < len; i++ ) struct_set(collapsed, group_labels[i].key, 1); }
    			
    			sections[page_current] = sect;
    		#endregion
    		
    		goto_item_highlight    = lerp_float(goto_item_highlight, 0, 30);
    		
    		return hh;
    	});
    #endregion
    
    #region search
    	tb_search = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ { search_text = str; })
    	                    .setFont(f_p2)
    	                    .setAlign(fa_left)
    	                    .setEmpty()
    	                    .setAutoupdate();
    	
    	search_text = "";
    	contents    = {};
    	goto_item   = noone;
    	goto_item_highlight = 0;
    	
    	var _pref_lists = [ pref_global, pref_appr, pref_node ];
    	
    	for (var j = 0, m = array_length(_pref_lists); j < m; j++) 
    	for (var i = 0, n = ds_list_size(_pref_lists[j]); i < n; i++) {
    		var _pr = _pref_lists[j][| i];
    		if(!is_struct(_pr)) continue;
    		
    		contents[$ _pr.key] = { page: j, item: _pr };
    	}
    
    	function goto(_tag) {
    		if(!struct_has(contents, _tag)) return self;
    		var _it = contents[$ _tag];
    		
    		if(page_current != _it.page)
    			page_current = _it.page;
    		goto_item = _it.item;
    		goto_item_highlight = 2;
    		
    		return self;
    	}
    #endregion

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	function onResize() {
	    panel_width   = w - padding * 2 - page_width;
		panel_height  = h - padding * 2;
		hotkey_height = panel_height - hotkey_cont_h - ui(32);
		
		sp_pref.resize(  panel_width, panel_height - 1);
		sp_hotkey.resize(panel_width, hotkey_height);
	}
	
	function drawContent(panel) {
	    draw_clear_alpha(COLORS.panel_bg_clear, 1);
	    
    	tb_search.setFocusHover(pFOCUS, pHOVER);
    	tb_search.draw(padding, padding, page_width - padding * 2 - ui(4), ui(24), search_text, [ mx, my ]);
    	
    	sp_page.verify(page_width - padding, panel_height - padding - ui(32));
    	sp_page.setFocusHover(pFOCUS, pHOVER);
    	sp_page.drawOffset(padding, padding + ui(32), mx, my);
        
    	if(should_restart) {
    		var _txt = "Restart recommended";
    		draw_set_text(f_p2b, fa_center, fa_center, COLORS._main_text_accent);
    		
    		var _rw = page_width - ui(8);
    		var _rh = string_height_ext(_txt, -1, _rw - ui(16)) + ui(8);
    		var _rx = ui(2);
    		var _ry = h - ui(2) - _rh;
    		
    		draw_sprite_stretched_ext(THEME.box_r5_clr, 0, _rx, _ry, _rw, _rh, COLORS._main_accent, 1);
    		draw_text_ext_add(_rx + _rw / 2, _ry + _rh / 2, _txt, -1, _rw - ui(16));
    	}
        
    	section_current = "";
    	var px = padding + page_width;
    	var py = padding;
    	var pw = w - padding * 2 - page_width;
    	var ph = h - padding + padding;
    	
    	draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
    	
    	switch(page_current) {
        	case 0 : //General
        		current_list = pref_global;
        		sp_pref.setFocusHover(pFOCUS, pHOVER);
        		sp_pref.drawOffset(px, py, mx, my);
    		    break;
    		    
    	    case 1 : //Interface
        		current_list = pref_appr;
        		sp_pref.setFocusHover(pFOCUS, pHOVER);
        		sp_pref.drawOffset(px, py, mx, my);
    		    break;
    		
    	    case 2 : //Nodes
        		current_list = pref_node;
        		sp_pref.setFocusHover(pFOCUS, pHOVER);
        		sp_pref.drawOffset(px, py, mx, my);
    		    break;
    		
    	    case 3 : //Theme
        		var _sp_x = ui(296);
        		var _sp_y = ui(28);
        		
        		var x1 = px + _sp_x - ui(8);
        		sp_theme.verify(_sp_x - ui(8), panel_height);
        		sp_theme.setFocusHover(pFOCUS, pHOVER);
        		sp_theme.drawOffset(px, py, mx, my);
        		
        		var _res_w = panel_width - _sp_x;
        		
        		tab_resources.setFocusHover(pFOCUS, pHOVER);
                tab_resources.draw(px + _sp_x + ui(32), py, _res_w - ui(64), ui(24), theme_page, [ mx, my ]);
        		
        		var sp = theme_pages[theme_page];
        		sp.verify(_res_w, panel_height - _sp_y);
        		sp.setFocusHover(pFOCUS, pHOVER);
        		sp.drawOffset(px + _sp_x, py + _sp_y, mx, my);
    		    break;
    		
    	    case 4 : //Hotkeys
        		if(mouse_press(mb_left, pFOCUS)) 
        			hk_editing = noone;
        		
        		var hk_w = panel_width;
        		var hk_h = hotkey_cont_h - ui(16);
        		var kdsp = keyboards_display;
        		var keys = keyboards_display.keys;
        		
        		var ks   = min(hk_w / kdsp.width, hk_h / kdsp.height);
        		var _kww = ks * kdsp.width;
        		var _khh = ks * kdsp.height;
        		
        		var _ksx = px + hk_w / 2 - _kww / 2;
        		var _ksy = py + hk_h / 2 - _khh / 2;
        		var _kp  = ui(2);
        		
        		var _keyUsing = {};
        		var _ctxObj   = hotkeyContext[hk_page];
        		var _cntx     = _ctxObj.context;
        		var _list     = _ctxObj.list;
        		
        		for (var j = 0, m = array_length(_list); j < m; j++) {
        			
        			var _ky   = _list[j];
        			var _kkey = _ky.key;
        			var _kmod = _ky.modi;
        			
        			if(_kkey == noone && _kmod == MOD_KEY.none) continue;
        			
        			if(!struct_has(_keyUsing, _kkey))
        				_keyUsing[$ _kkey] = {};
        			
        			var _kuse = _keyUsing[$ _kkey];
        			if(!struct_has(_kuse, _kmod))
        				_kuse[$ _kmod] = [];
        				
        			array_append(_kuse[$ _kmod], _ky);
        		}
        		
        		var _mc = MOD_KEY.ctrl;
        		var _ms = MOD_KEY.shift;
        		var _ma = MOD_KEY.alt;
        		
        		var c_control = CDEF.orange, kc_control = colorMultiply(CDEF.main_dkgrey, c_control);
        		var c_shift   = CDEF.blue,   kc_shift   = colorMultiply(CDEF.main_dkgrey, c_shift);
        		var c_alt     = CDEF.lime,   kc_alt     = colorMultiply(CDEF.main_dkgrey, c_alt);
        		var _sel      = true;
        		
        		var _mod_arr = [ _mc, _ms, _ma, _mc | _ms, _mc | _ma, _ms | _ma, _mc | _ms | _ma ];
        		var _mod_clr = [ 
        		    [ [ 0, c_control ]                               ], 
        		    [ [ 0, c_shift   ]                               ], 
        		    [ [ 0, c_alt     ]                               ], 
        		    [ [ 1, c_control ], [ 2, c_shift ]               ], 
        		    [ [ 1, c_control ], [ 2, c_alt   ]               ], 
        		    [ [ 1, c_shift   ], [ 2, c_alt   ]               ], 
        		    [ [ 3, c_control ], [ 4, c_shift ], [ 5, c_alt ] ], 
    		    ];
        		
        		var _cur_mod  = MOD_KEY.ctrl  * key_mod_press(CTRL)
        		              + MOD_KEY.shift * key_mod_press(SHIFT)
        		              + MOD_KEY.alt   * key_mod_press(ALT)
        		
        		var _cmod = _cur_mod == MOD_KEY.none? hk_modifiers : _cur_mod;
        		
        		draw_set_text(f_p4, fa_center, fa_center);
        		for (var i = 0, n = array_length(keys); i < n; i++) {
        			var _key = keys[i];
        			var _kx  = _ksx + _key.x * ks;
        			var _ky  = _ksy + _key.y * ks;
        			var _kw  = _key.w * ks;
        			var _kh  = _key.h * ks;
        			var _vk  = _key.vk;
        			
        			_kx += _kw / 2 - (_kw - _kp) / 2;
        			_ky += _kh / 2 - (_kh - _kp) / 2;
        			_kw -= _kp;
        			_kh -= _kp;
        			
        			if(_vk == -1) {
        				draw_sprite_stretched_ext(THEME.ui_panel, 0, _kx, _ky, _kw, _kh, CDEF.main_black, 0.3);
        				continue;
        			}
        			
        			var _tc  = CDEF.main_grey;
        			var _hov = pHOVER && point_in_rectangle(mx, my, _kx - _kp, _ky - _kp, _kx + _kw + _kp - 1, _ky + _kh + _kp - 1);
        			
        			if(_vk == vk_control) {
        				_sel = bool(MOD_KEY.ctrl & _cmod);
        				
        				draw_sprite_stretched_ext(THEME.ui_panel, 0, _kx, _ky, _kw, _kh, _sel? c_control : kc_control);
        				_tc = _sel? kc_control : c_control;
        				
        				if(mouse_press(mb_left, pFOCUS && _hov)) hk_modifiers ^= MOD_KEY.ctrl;
        				
        			} else if(_vk == vk_shift) {
        				_sel = bool(MOD_KEY.shift & _cmod);
        				
        				draw_sprite_stretched_ext(THEME.ui_panel, 0, _kx, _ky, _kw, _kh, _sel? c_shift : kc_shift);
        				_tc = _sel? kc_shift : c_shift;
        				
        				if(mouse_press(mb_left, pFOCUS && _hov)) hk_modifiers ^= MOD_KEY.shift;
        					
        			} else if(_vk == vk_alt) {
        				_sel = bool(MOD_KEY.alt & _cmod);
        				
        				draw_sprite_stretched_ext(THEME.ui_panel, 0, _kx, _ky, _kw, _kh, _sel? c_alt : kc_alt);
        				_tc = _sel? kc_alt : c_alt;
        				
        				if(mouse_press(mb_left, pFOCUS && _hov)) hk_modifiers ^= MOD_KEY.alt;
        					
        			} else if(struct_has(_keyUsing, _vk) && struct_has(_keyUsing[$ _vk], _cmod)) {
        				draw_sprite_stretched_ext(THEME.ui_panel, 0, _kx, _ky, _kw, _kh, CDEF.main_ltgrey);
        				draw_sprite_stretched_add(THEME.ui_panel, 1, _kx, _ky, _kw, _kh, c_white, 0.1);
        				_tc = CDEF.main_mdblack;
        				
        				var _act = _keyUsing[$ _vk][$ _cmod];
        				
        				if(_hov) {
        					TOOLTIP = new tooltipHotkey_assign(_act, key_get_name(_vk, _cmod));
        					
        					if(mouse_press(mb_left, pFOCUS)) {
        						if(hotkey_focus_index >= array_length(_act))
        							hotkey_focus_index = 0;
        							
        						hotkey_focus           = _act[hotkey_focus_index];
        						hotkey_focus_highlight = _act[hotkey_focus_index];
        						hotkey_focus_high_bg   = 1;
        						
        						hotkey_focus_index++;
        					}
        				}
        				
        			} else {
        				draw_sprite_stretched_ext(THEME.ui_panel, 0, _kx, _ky, _kw, _kh, CDEF.main_black);
        				_tc  = CDEF.main_grey;
        				
        				if(_hov) TOOLTIP = new tooltipHotkey_assign(noone, key_get_name(_vk, _cmod));
        			}
        			
        			if(struct_has(_keyUsing, _vk)) {
        			    var _mkx = _kx + ui(6);
        			    var _mky = _ky + ui(6);
        			    
        			    var _modKeys = _keyUsing[$ _vk];
        			    for( var j = 0, m = array_length(_mod_arr); j < m; j++ ) {
        			        var _md = _mod_arr[j];
        			        if(!struct_has(_modKeys, _md)) continue;
        			        
        			        var _mspr = _mod_clr[j];
        			        for( var k = 0, p = array_length(_mspr); k < p; k++ )
        			            draw_sprite_ext(THEME.circle_hotkey, _mspr[k][0], _mkx, _mky, 1, 1, 0, _mspr[k][1]);
        			        _mkx += ui(5);
        			    }
        			}
        			
        			draw_sprite_stretched_add(THEME.ui_panel, 1, _kx, _ky, _kw, _kh, c_white, 0.1 + _hov * 0.2);
        			
        			if(is_string(_key.key)) {
        				draw_set_color(_tc);
        				draw_set_alpha(1);
        				draw_text(_kx + _kw / 2, _ky + _kh / 2, _key.key);
        			}
        			
        		}
        		
        		var _ppy = py + hotkey_cont_h;
        		
        		hk_scroll.font = f_p2;
        		hk_scroll.setFocusHover(pFOCUS, pHOVER);
        		hk_scroll.draw(px, _ppy, ui(200), ui(24), hk_page, [ mx, my ], x, y);
        		
        		sp_hotkey.setFocusHover(pFOCUS, pHOVER);
        		sp_hotkey.drawOffset(px, _ppy + ui(32), mx, my);
    	    break;
    	}
    	
	}
	
	static onClose = function() {
	    ds_list_destroy(pref_global);
	}
	
}