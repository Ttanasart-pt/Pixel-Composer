/// @description init
event_inherited();

#region data
	dialog_w   = min(WIN_W - ui(16), ui(1000));
	dialog_h   = min(WIN_H - ui(16), ui(700));
	page_width = ui(160);
	// title_height = 8;
	
	destroy_on_click_out = true;
	destroy_on_escape    = false;
	
	should_restart = false;
	
	font = f_p2;
#endregion

#region size
	dialog_resizable = true;
	dialog_w_min = ui(640);
	dialog_h_min = ui(480);
	
	panel_width   = dialog_w - ui(padding + padding) - page_width;
	panel_height  = dialog_h - ui(title_height + padding);
	
	hotkey_cont_h = ui(240);
	hotkey_height = panel_height - hotkey_cont_h - ui(32);
	
	onResize = function() /*=>*/ {
		panel_width   = dialog_w - ui(padding + padding) - page_width;
		panel_height  = dialog_h - ui(title_height + padding);
		hotkey_height = panel_height - hotkey_cont_h - ui(32);
		
		sp_page.resize(page_width - ui(4), panel_height);
		
		sp_pref.resize(  panel_width, panel_height);
		sp_hotkey.resize(panel_width, hotkey_height);
		sp_colors.resize(panel_width, panel_height - ui(40));
	}
#endregion

#region pages
	page_current = 0;
	page[0] = __txtx("pref_pages_general", "General");
	page[1] = __txtx("pref_pages_interface", "Interface");
	page[2] = __txt("Nodes");
	page[3] = __txt("Theme");
	page[4] = __txt("Hotkeys");
	
	section_current = "";
	sections = array_create(array_length(page));
	
	sp_page = new scrollPane(page_width - ui(4), panel_height, function(_y, _m, _r) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var ww = sp_page.surface_w;
		var hh = 0;
		
		var yl = _y;
		var hg = line_get_height(f_p0, 16);
		var hs = line_get_height(f_p1, 8);
		
		for(var i = 0; i < array_length(page); i++) {
			if(i == page_current) draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_text_accent);
			else                  draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_inner);
			
			if(sHOVER && point_in_rectangle(_m[0], _m[1], 0, yl, ww, yl + hg)) {
				sp_page.hover_content = true;
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, yl, ww, hg, CDEF.main_white, 1);
				
				if(i != page_current && mouse_click(mb_left, sFOCUS)) {
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
				
					draw_set_text(f_p1, fa_left, fa_center, section_current == sect[0]? COLORS._main_text : COLORS._main_text_sub);
				
					if(sHOVER && point_in_rectangle(_m[0], _m[1], 0, yl, ww, yl + hs - 1)) {
						sp_page.hover_content = true;
						if(mouse_press(mb_left, sFOCUS))
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
			__txtx("pref_save_backups", "Backup saves"),
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
				if(str < 0) return;
				PREFERENCES.local = locals[str];
				PREF_SAVE();
			}, false)
		));
		
		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
			__txtx("pref_ui_font", "Overwrite UI font") + "*",
			"font_overwrite",
			new textBox(TEXTBOX_INPUT.text, function(txt) /*=>*/ { PREFERENCES.font_overwrite = txt; PREF_SAVE(); })
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
			__txtx("pref_connection_type", "Connection type"),
			"curve_connection_line",
			new buttonGroup([ THEME.icon_curve_connection, THEME.icon_curve_connection, THEME.icon_curve_connection, THEME.icon_curve_connection ], 
			function(val) /*=>*/ { PREFERENCES.curve_connection_line = val; PREF_SAVE(); })
		));
		
		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
			__txtx("pref_connection_thickness", "Connection thickness"),
			"connection_line_width",
			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { PREFERENCES.connection_line_width = real(str); PREF_SAVE(); })
		));
		
		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
			__txtx("pref_connection_curve_smoothness", "Connection curve smoothness"),
			"connection_line_sample",
			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { PREFERENCES.connection_line_sample = real(str); PREF_SAVE(); })
		));
		
		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
			__txtx("pref_connection_aa", "Connection anti aliasing"),
			"connection_line_aa",
			new textBox(TEXTBOX_INPUT.number, function(str) /*=>*/ { PREFERENCES.connection_line_aa = max(1, real(str)); PREF_SAVE(); })
		));
		
		ds_list_add(pref_appr, new __Panel_Linear_Setting_Item_Preference(
			__txtx("pref_connection_anim", "Connection line animation"),
			"connection_line_transition",
			new checkBox(function() /*=>*/ { PREFERENCES.connection_line_transition = !PREFERENCES.connection_line_transition; PREF_SAVE(); })
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
	
	// ds_list_add(pref_node, __txt("Node"));
	
		ds_list_add(pref_node, new __Panel_Linear_Setting_Item_Preference(
			__txtx("pref_node_param_show", "Show paramater on new node"),
			"node_param_show",
			new checkBox(function() /*=>*/ { PREFERENCES.node_param_show = !PREFERENCES.node_param_show; PREF_SAVE(); })
		));
		
		ds_list_add(pref_node, new __Panel_Linear_Setting_Item_Preference(
			__txtx("pref_node_param_width", "Default param width"),
			"node_param_width",
			new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { PREFERENCES.node_param_width = val; PREF_SAVE(); })
		));
		
		ds_list_add(pref_node, new __Panel_Linear_Setting_Item_Preference(
			__txtx("pref_node_3d_preview", "Preview surface size"),
			"node_3d_preview_size",
			new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { PREFERENCES.node_3d_preview_size = clamp(val, 16, 1024); PREF_SAVE(); })
		));
	
		ds_list_add(pref_node, new __Panel_Linear_Setting_Item_Preference(
			__txtx("pref_file_watcher_delay", "File watcher delay (s)"),
			"file_watcher_delay",
			new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { PREFERENCES.file_watcher_delay = val; PREF_SAVE(); })
		));
	
#endregion

#region theme
	themes = [];
	var f = file_find_first(DIRECTORY + "Themes/*", fa_directory);
	while(f != "") {
		var _path = $"{DIRECTORY}Themes/{f}";
		if(directory_exists(_path)) {
			var _metaPath = _path + "/meta.json";
			if(!file_exists_empty(_metaPath)) {
				var _item = new scrollItem(f, THEME.circle, 0, COLORS._main_accent);
				    _item.tooltip   = "Theme made for earlier version.";
				array_push(themes, _item);
			} else {
				var _meta = json_load_struct(_metaPath);
				var _item = new scrollItem(_meta.name, _meta.version >= VERSION? noone : THEME.circle, 0, COLORS._main_accent);
				    _item.data      = f;
					
				if(_meta.version < VERSION)
				    _item.tooltip = "Theme made for earlier version.";
				array_push(themes, _item);
			}
		}
		
		f = file_find_next();
	}
	file_find_close();
	
	sb_theme = new scrollBox(themes, function(index) { 
			var thm = themes[index].data;
			if(PREFERENCES.theme == thm) return;
			
			PREFERENCES.theme = thm;
			PREF_SAVE();
			
			loadGraphic(thm);
			loadColor(thm);
			loadFonts();
		}, false);
	sb_theme.align = fa_left;
	
	sp_colors = new scrollPane(panel_width, panel_height - ui(40), function(_y, _m, _r) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var hh	 = 0;
		var th   = line_get_height(font);
		var x1	 = sp_colors.surface_w;
		var yy	 = _y + ui(8);
		var padd = ui(6);
		var ind	 = 0;
		
		var cp = ui(0)
		var cw = ui(100);
		var ch = th - cp * 2;
		var cx = x1 - cw - ui(8);
		var category = "";
		
		var sect = [];
		var psect = "";
		
		for( var i = 0, n = array_length(COLOR_KEYS); i < n; i++ ) {
			var key = COLOR_KEYS[i];
			var val = variable_struct_get(COLORS, key);
			
			if(search_text != "" && string_pos(string_lower(search_text), string_lower(key)) == 0)
				continue;
				
			if(is_array(val)) continue;
			var spl = string_splice(key, "_");
			var cat = spl[0] == ""? spl[1] : spl[0];
			if(cat != category) {
				category = cat;
				var _sect = string_title(category);
				
				draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
				draw_text_add(ui(8), yy - ui(4), _sect);
				
				array_push(sect, [ _sect, sp_colors, hh + ui(12) ]);
				if(yy >= 0 && section_current == "") 
					section_current = psect;
				psect = _sect;
				
				yy += string_height(category) + ui(8);
				hh += string_height(category) + ui(8);
				ind = 0;
			}
			
			if(ind % 2 == 0) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, yy - padd, sp_colors.surface_w, th + padd * 2, COLORS.dialog_preference_prop_bg, 1);
					
			var keyStr = string_replace_all(key, "_", " ");
			keyStr = string_replace(keyStr, cat + " ", "");
			keyStr = string_title(keyStr);
			
			draw_set_text(font, fa_left, fa_center, COLORS._main_text);
			draw_text_add(ui(24), yy + th / 2, keyStr);
			
			var b = buttonInstant(THEME.button_def, cx, yy + cp, cw, ch, _m, sFOCUS, sHOVER && sp_colors.hover);
			draw_sprite_stretched_ext(THEME.palette_mask, 1, cx + ui(2), yy + ui(2), cw - ui(4), ch - ui(4), val, 1);
			
			if(b) sp_colors.hover_content = true;
			if(b == 2) {
				var dialog = dialogCall(o_dialog_color_selector, WIN_W / 2, WIN_H / 2);
				dialog.setDefault(val);
				self.key = key;
				dialog.onApply = function(color) { 
					COLORS[$ key] = color; 
					overrideColor(key);
				};
				
				dialog.selector.onApply = dialog.onApply;
				
				addChildren(dialog);
			}
			
			yy += th + padd + ui(6);
			hh += th + padd + ui(6);
			ind++;
		}
		
		sections[page_current] = sect;
		
		return hh;
	});
	
	function overrideColor(key) {
		var path = $"{DIRECTORY}Themes/{PREFERENCES.theme}/override.json";
		var json = file_exists_empty(path)? json_load_struct(path) : {};
		
		json[$ key] = COLORS[$ key];
		json_save_struct(path, json, true);
	}
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
		var _hov      = sHOVER && sp_hotkey.hover;
		var modified  = false;
		
		var _ctxObj = hotkeyContext[hk_page];
		var _cntx   = _ctxObj.context;
		var _list   = _ctxObj.list;
		var _yy     = yy + hh;
		
		var _search = string_lower(search_text);
		
		for (var j = 0, m = array_length(_list); j < m; j++) {
			
			var key   = _list[j];
			var name  = __txt(key.name);
			var dk    = key_get_name(key.key, key.modi);
			
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
				// draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bw, bh, COLORS._main_accent);
				cc = COLORS._main_text_accent;
				
			} else {
				if(_hov && point_in_rectangle(_m[0], _m[1], bx, by, bx + bw, by + bh)) {
					// draw_sprite_stretched_ext(THEME.ui_panel, 1, bx, by, bw, bh, CDEF.main_ltgrey);
					sp_hotkey.hover_content = true;
					cc = CDEF.main_white;
					
					if(mouse_press(mb_left, sFOCUS)) {
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
				var b    = buttonInstant(THEME.button_hide, bx, by, ui(24), ui(24), _m, sFOCUS, _hov, __txt("Reset"), THEME.refresh_16);
				
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
	
	sp_pref = new scrollPane(panel_width, panel_height, function(_y, _m, _r) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		var ww   = sp_pref.surface_w;
		var hh	 = 0;
		var th	 = line_get_height(font, 6);
		var x1	 = sp_pref.surface_w;
		var yy	 = _y + ui(8);
		var padd = ui(6);
		var ind	 = 0;
		
		for(var i = 0; i < ds_list_size(current_list); i++) {
			var _pref = current_list[| i];
			if(is_string(_pref)) continue;
			
			if(search_text != "" && string_pos(string_lower(search_text), string_lower(_pref.name)) == 0)
				continue;
			
			_pref.editWidget.register(sp_pref);
		}
		
		var sect = [];
		var psect = "";
		
		for(var i = 0; i < ds_list_size(current_list); i++) {
			var _pref = current_list[| i];
			
			if(is_string(_pref)) {
				draw_set_text(f_p1, fa_left, fa_top, COLORS._main_text_sub);
				draw_text_add(ui(8), yy, _pref);
				
				array_push(sect, [ _pref, sp_pref, hh + ui(12) ]);
				if(yy >= 0 && section_current == "") 
					section_current = psect;
				psect = _pref;
				
				yy += string_height(_pref) + ui(8);
				hh += string_height(_pref) + ui(8);
				ind = 0;
				continue;
			}
			
			var name = _pref.name;
			var data = _pref.data();
			
			if(search_text != "" && string_pos(string_lower(search_text), string_lower(name)) == 0)
				continue;
			
			if(ind % 2 == 0) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, 0, yy - padd, ww, max(_pref.editWidget.h, th) + padd * 2, COLORS.dialog_preference_prop_bg, 1);
			
			if(goto_item == _pref) {
				if(goto_item_highlight == 2) sp_pref.setScroll(-hh);
				if(goto_item_highlight == 0) goto_item = noone;
				
				draw_sprite_stretched_add(THEME.ui_panel_bg, 0, 0, yy - padd, ww, max(_pref.editWidget.h, th) + padd * 2, COLORS._main_accent, min(1, goto_item_highlight) * 0.5);
			}
				
			draw_set_text(font, fa_left, fa_center, COLORS._main_text);
			draw_text_add(ui(24), yy + th / 2, name);
			
			if(_pref.is_patreon) {
				var spr_x = ui(20);
				var spr_y = yy + ui(4);
				
				BLEND_SUBTRACT
				gpu_set_colorwriteenable(0, 0, 0, 1);
				draw_sprite_ext(s_patreon_supporter, 0, spr_x, spr_y, -1, 1, 0, c_white, 1);
				gpu_set_colorwriteenable(1, 1, 1, 1);
				BLEND_NORMAL
			
				draw_sprite_ext(s_patreon_supporter, 1, spr_x, spr_y, -1, 1, 0, COLORS._main_accent, 1);
			}
			
			_pref.editWidget.setFocusHover(sFOCUS, sHOVER && sp_pref.hover); 
			
			var widget_w = ui(260);
			var widget_h = th;
			
				 if(is_instanceof(_pref.editWidget, textBox))         widget_w = _pref.editWidget.input == TEXTBOX_INPUT.text? ui(400) : widget_w;
			else if(is_instanceof(_pref.editWidget, folderArrayBox))  widget_w = ui(400);
			
			var widget_x = x1 - ui(4) - widget_w;
			var widget_y = yy;
			
			if(_pref.getDefault != noone)
				widget_w -= ui(32 + 8);
				
			var params  = new widgetParam(widget_x, widget_y, widget_w, widget_h, data, {}, _m, _r[0], _r[1]);
			params.s    = th;
			params.font = font;
			
			if(instanceof(_pref.editWidget) == "checkBox") params.halign = fa_center;
			var wdh = _pref.editWidget.drawParam(params) ?? 0;
			if(_pref.editWidget.inBBOX(_m)) sp_pref.hover_content = true;
			
			if(_pref.getDefault != noone) {
				var _defVal = is_method(_pref.getDefault)? _pref.getDefault() : _pref.getDefault;
				var _bs = ui(32);
				var _bx = x1 - ui(4) - _bs;
				var _by = yy + wdh / 2 - _bs / 2;
					
				if(isEqual(data, _defVal))
					draw_sprite_ext(THEME.refresh_16, 0, _bx + _bs / 2, _by + _bs / 2, 1, 1, 0, COLORS._main_icon_dark);
				else {
					if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, _m, sFOCUS, sHOVER && sp_pref.hover, __txt("Reset"), THEME.refresh_16) == 2)
						_pref.onEdit(_defVal);
				}
			}
				
			yy += wdh + padd + ui(6);
			hh += wdh + padd + ui(6);
			ind++;
		}
		
		sections[page_current] = sect;
		goto_item_highlight    = lerp_float(goto_item_highlight, 0, 30);
		
		return hh;
	});
#endregion

#region search
	tb_search = new textBox(TEXTBOX_INPUT.text, function(str) /*=>*/ { search_text = str; });
	tb_search.align	= fa_left;
	
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
