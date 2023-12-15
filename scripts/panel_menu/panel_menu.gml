function Panel_Menu() : PanelContent() constructor {
	title	 = __txt("Menu");
	auto_pin = true;
	
	noti_flash		 = 0;
	noti_flash_color = COLORS._main_accent;
	noti_icon		 = noone;
	noti_icon_show   = 0;
	noti_icon_time   = 0;
	
	vertical_break    = ui(240);
	version_name_copy = 0;
	
	var _right = PREFERENCES.panel_menu_right_control;
	if(_right) action_buttons = ["exit", "maximize", "minimize", "fullscreen"];
	else	   action_buttons = ["exit", "minimize", "maximize", "fullscreen"];
	
	#region file
	menu_file_nondemo = [
		menuItem(__txt("New"),				function() { NEW(); }, THEME.new_file, ["", "New file"]),
		menuItem(__txt("Open") + "...",		function() { LOAD(); }, THEME.noti_icon_file_load, ["", "Open"])
			.setShiftMenu(menuItem(__txt("Open in safe mode") + "...",		function() { LOAD(true); }, THEME.noti_icon_file_load)),
		menuItem(__txt("Save"),				function() { SAVE(); }, THEME.save, ["", "Save"]),
		menuItem(__txt("Save as") + "...",	function() { SAVE_AS(); }, THEME.save, ["", "Save as"]),
		menuItem(__txt("Save all"),			function() { SAVE_ALL(); }, THEME.icon_save_all, ["", "Save all"]),
		menuItem(__txt("Recent files"),		function(_dat) { 
				var arr = [];
				for(var i = 0; i < min(10, ds_list_size(RECENT_FILES)); i++)  {
					var _rec = RECENT_FILES[| i];
					array_push(arr, menuItem(_rec, function(_dat) { LOAD_PATH(_dat.name); }));
				}
				
				return submenuCall(_dat, arr);
		}).setIsShelf(),
		menuItem(__txtx("panel_menu_auto_save_folder", "Open autosave folder"), function() { shellOpenExplorer(DIRECTORY + "autosave"); }, THEME.save_auto),
		menuItem(__txt("Import"),			 function(_dat) { 
			var arr = [
				menuItem(__txt("Portable project (.zip)") + "...", function() { __IMPORT_ZIP(); }),
			];
			
			return submenuCall(_dat, arr);
		}).setIsShelf(),
		menuItem(__txt("Export"),			 function(_dat) { 
			var arr = [
				menuItem(__txt("Portable project (.zip)") + "...", function() { exportPortable(PROJECT); }),
			];
			
			return submenuCall(_dat, arr);
		}).setIsShelf(),
		-1,
	];
	
	menu_file = [
		menuItem(__txt("Preferences") + "...", function() { dialogCall(o_dialog_preference); }, THEME.gear),
		menuItem(__txt("Splash screen"), function() { dialogCall(o_dialog_splash); }),
		-1,
		menuItem(__txt("Addons"), function(_dat) { 
			var arr = [
				menuItem(__txt("Addons") + "...", function() { dialogPanelCall(new Panel_Addon()); }),
				menuItem(__txtx("panel_menu_addons_key", "Key displayer"), function() { 
					if(instance_exists(addon_key_displayer)) {
						instance_destroy(addon_key_displayer);
						return;
					}
					
					instance_create_depth(0, 0, 0, addon_key_displayer);
				}),
				-1
			];
			
			for( var i = 0, n = array_length(ADDONS); i < n; i++ ) {
				var _dir = ADDONS[i].name;
				array_push(arr, menuItem(_dir, function(_dat) { addonTrigger(_dat.name); } ));
			}
			
			return submenuCall(_dat, arr);
		}, THEME.addon_icon ).setIsShelf(),
		-1,
		menuItem(__txt("Fullscreen"),			 function() { winMan_setFullscreen(!window_is_fullscreen); },, ["", "Fullscreen"]),
		menuItem(__txt("Close current project"), function() { PANEL_GRAPH.close(); },, [ "", "Close file" ]),
		menuItem(__txt("Close all projects"),	 function() { for( var i = array_length(PROJECTS) - 1; i >= 0; i-- ) closeProject(PROJECTS[i]); },, [ "", "Close all" ]),
		menuItem(__txt("Close program"),		 function() { window_close(); },, [ "", "Close program" ]),
	]; 
	
	if(!DEMO) menu_file = array_append(menu_file_nondemo, menu_file);
	#endregion
	
	#region help
	menu_help = [ 
		menuItem(__txtx("panel_menu_help_video", "Tutorial videos"), function() {
			url_open("https://www.youtube.com/@makhamdev");
		}, THEME.youtube),
		menuItem(__txtx("panel_menu_help_wiki", "Community Wiki"), function() {
			url_open("https://pixel-composer.fandom.com/wiki/Pixel_Composer_Wiki");
		}, THEME.wiki),
		-1, 
		menuItem(__txtx("panel_menu_local_directory", "Open local directory"), function() {
			shellOpenExplorer(DIRECTORY);
		}, THEME.folder),
		menuItem(__txtx("panel_menu_autosave_directory", "Open autosave directory"), function() {
			shellOpenExplorer(DIRECTORY + "autosave/");
		}, THEME.folder),
		menuItem(__txtx("panel_menu_reset_default", "Reset default collection, assets"), function() {
			zip_unzip("data/Collections.zip", DIRECTORY + "Collections");
			zip_unzip("data/Assets.zip", DIRECTORY + "Assets");
		}),
		-1,
		menuItem(__txtx("panel_menu_connect_patreon", "Connect to Patreon"), function() {
			dialogPanelCall(new Panel_Patreon());
		}, THEME.patreon),
	];
	#endregion
	
	#region //////// MENU ////////
	menus = [
		[ __txt("File"), menu_file ],
		[ __txt("Edit"), [
			menuItem(__txt("Undo"), function() { UNDO(); }, THEME.undo, ["", "Undo"]),
			menuItem(__txt("Redo"), function() { REDO(); }, THEME.redo, ["", "Redo"]),
			menuItem(__txt("History"), function() { dialogPanelCall(new Panel_History()); }),
		]],
		[ __txt("Preview"), [
			menuItem(__txtx("panel_menu_center_preview", "Center preview"), function() { PANEL_PREVIEW.do_fullView = true; }, THEME.icon_center_canvas, ["Preview", "Focus content"]), 
			menuItem(__txtx("panel_menu_save_current_preview_as", "Save current preview as..."), function() { PANEL_PREVIEW.saveCurrentFrame(); }, noone, ["Preview", "Save current frame"]), 
			menuItemGroup(__txtx("panel_menu_preview_background", "Preview background"), [
				[ s_menu_transparent,	function() { PANEL_PREVIEW.canvas_bg = -1; } ],
				[ s_menu_white,			function() { PANEL_PREVIEW.canvas_bg = c_white; } ],
				[ s_menu_black,			function() { PANEL_PREVIEW.canvas_bg = c_black; } ],
			]),
		]], 
		[ __txt("Animation"), [
			menuItem(__txtx("panel_menu_animation_setting", "Animation setting..."), function() { 
				var dia = dialogPanelCall(new Panel_Animation_Setting()); 
				dia.anchor = ANCHOR.none;
			}, THEME.animation_setting),
			-1,
			menuItem(__txtx("panel_menu_animation_scaler", "Animation scaler..."), function() { 
				dialogPanelCall(new Panel_Animation_Scaler()); 
			}, THEME.animation_timing),
		]],
		[ __txt("Rendering"), [
			menuItem(__txtx("panel_menu_render_all_nodes", "Render all nodes"), function() { 
				RENDER_ALL_REORDER 
			}, [ THEME.sequence_control, 1 ], ["", "Render all"]),
			menuItem(__txtx("panel_menu_execute_exports", "Execute all export nodes"), function() { 
				var key = ds_map_find_first(PROJECT.nodeMap);
				repeat(ds_map_size(PROJECT.nodeMap)) {
					var node = PROJECT.nodeMap[? key];
					key = ds_map_find_next(PROJECT.nodeMap, key);
					
					if(!node.active) continue;
					if(instanceof(node) != "Node_Export") continue;
					
					node.doInspectorAction();
				}
			}),
			menuItem(__txtx("panel_menu_export_render_all", "Render disabled node when export"),		
				function() { PREFERENCES.render_all_export = !PREFERENCES.render_all_export; },,,	
				function() { return PREFERENCES.render_all_export; } ),
		]],
		[ __txt("Panels"), [
			menuItem(__txt("Workspace"), function(_dat) { 
				var arr = [], lays = [];
				var f   = file_find_first(DIRECTORY + "layouts/*", 0);
				while(f != "") {
					array_push(lays, filename_name_only(f));
					f = file_find_next();
				}
				
				array_push(arr, menuItem(__txtx("panel_menu_save_layout", "Save layout"), function() {
					var dia = dialogCall(o_dialog_file_name, mouse_mx + ui(8), mouse_my + ui(8));
					dia.name = PREFERENCES.panel_layout_file;
					dia.onModify = function(name) { 
						var cont = panelSerialize();
						json_save_struct(DIRECTORY + "layouts/" + name + ".json", cont);
					};
				}));
				
				array_push(arr, menuItem(__txtx("panel_menu_reset_layout", "Reset layout"), function() {
					resetPanel();
				},, [ "", "Reset layout" ]));
				array_push(arr, -1);
				
				for(var i = 0; i < array_length(lays); i++)  {
					array_push(arr, menuItem(lays[i], 
						function(_dat) { 
							PREFERENCES.panel_layout_file = _dat.name;
							PREF_SAVE();
							setPanel();
						},,, function(item) { return item.name == PREFERENCES.panel_layout_file; } ));
				}
				
				return submenuCall(_dat, arr);
			}).setIsShelf(),
			-1,
			menuItem(__txt("Collections"),		function() { panelAdd("Panel_Collection", true) },,,	function() { return findPanel("Panel_Collection") != noone; } ),
			menuItem(__txt("Graph"),			function() { panelAdd("Panel_Graph", true) },,,			function() { return findPanel("Panel_Graph") != noone; } ),
			menuItem(__txt("Preview"),			function() { panelAdd("Panel_Preview", true) },,,		function() { return findPanel("Panel_Preview") != noone; } ),
			menuItem(__txt("Inspector"),		function() { panelAdd("Panel_Inspector", true) },,,		function() { return findPanel("Panel_Inspector") != noone; } ),
			menuItem(__txt("Workspace"),		function() { panelAdd("Panel_Workspace", true) },,,		function() { return findPanel("Panel_Workspace") != noone; } ),
			menuItem(__txt("Animation"),		function() { panelAdd("Panel_Animation", true) },,,		function() { return findPanel("Panel_Animation") != noone; } ),
			menuItem(__txt("Notifications"),	function() { panelAdd("Panel_Notification", true) },,,	function() { return findPanel("Panel_Notification") != noone; } ),
			menuItem(__txtx("panel_globalvar", "Global Variables"),	function() { panelAdd("Panel_Globalvar", true) },,,		function() { return findPanel("Panel_Globalvar") != noone; } ),
			
			menuItem(__txt("Nodes"), function(_dat) { 
				return submenuCall(_dat, [
					menuItem(__txt("Align"),	function() { panelAdd("Panel_Node_Align", true) },,,	function() { return findPanel("Panel_Node_Align") != noone; } ),
					menuItem(__txt("Nodes"),	function() { panelAdd("Panel_Nodes", true) },,,			function() { return findPanel("Panel_Nodes") != noone; } ),
					menuItem(__txt("Tunnels"),	function() { panelAdd("Panel_Tunnels", true) },,,		function() { return findPanel("Panel_Tunnels") != noone; } ),
				]);
			} ).setIsShelf(),
			
			menuItem(__txt("Color"), function(_dat) { 
				return submenuCall(_dat, [
					menuItem(__txt("Color"),		function() { panelAdd("Panel_Color", true) },,,		function() { return findPanel("Panel_Color") != noone; } ),
					menuItem(__txt("Palettes"),		function() { panelAdd("Panel_Palette", true) },,,	function() { return findPanel("Panel_Palette") != noone; } ),
					menuItem(__txt("Gradients"),	function() { panelAdd("Panel_Gradient", true) },,,	function() { return findPanel("Panel_Gradient") != noone; } ),
				]);
			} ).setIsShelf(),
		]],
		[ __txt("Help"), menu_help ],
	]; 
	#endregion
	
	if(TESTING) { #region
		array_push(menus, [ __txt("Dev"), [
			menuItem(__txtx("panel_debug_console", "Debug console"), function() { 
				panelAdd("Panel_Console", true)
			}),
			menuItem(__txtx("panel_debug_overlay", "Debug overlay"), function() { 
				show_debug_overlay(true);
			}),
			menuItem(__txtx("panel_menu_tester", "Tester"), function() { 
				var dia = dialogPanelCall(new Panel_Test());
				dia.destroy_on_click_out = false;
			}),
			-1, 
			
			menuItem(__txtx("panel_menu_test_load_all", "Load all current collections"), function() { 
				__test_load_current_collections();
			}),
			menuItem(__txtx("panel_menu_test_update_all", "Update all current collections"), function() { 
				__test_update_current_collections();
			}),
			menuItem(__txtx("panel_menu_test_add_meta", "Add metadata to current collections"), function() { 
				__test_metadata_current_collections();
			}),
			menuItem(__txtx("panel_menu_test_update_sam", "Update sample projects"), function() { 
				__test_update_sample_projects();
			}),
			-1,
			menuItem(__txtx("panel_menu_test_load_nodes", "Load all nodes"), function() { 
				__test_load_all_nodes();
			}),
			menuItem(__txtx("panel_menu_test_gen_guide", "Generate node guide"), function() { 
				var dia = dialogPanelCall(new Panel_Node_Data_Gen());
				dia.destroy_on_click_out = false;
			}),
			menuItem(__txtx("panel_menu_test_gen_theme", "Generate theme object"), function() { 
				__test_generate_theme();
			}),
			-1,
			menuItem(__txtx("panel_menu_test_crash", "Force crash"), function() { 
				print(1 + "a");
			}),
			-1,
			menuItem(__txt("Misc."), function(_dat) { 
				return submenuCall(_dat, [
					menuItem(__txtx("panel_menu_node_credit", "Node credit dialog"), function() { var dia = dialogPanelCall(new Panel_Node_Cost()); }),
				]);
			} ).setIsShelf(),
		]]);
	} #endregion
	
	menu_help_steam = array_clone(menu_help);
	array_push(menu_help_steam, -1, 
		menuItem(__txtx("panel_menu_steam_workshop", "Steam Workshop"), function() {
			steam_activate_overlay_browser("https://steamcommunity.com/app/2299510/workshop/");
		}, THEME.steam) );
	
	function onFocusBegin() { PANEL_MENU = self; }
	
	function setNotiIcon(icon) { #region
		noti_icon = icon;
		noti_icon_time = 90;
	} #endregion
	
	function undoUpdate() { #region
		var txt;
		
		if(ds_stack_empty(UNDO_STACK)) {
			txt = __txt("Undo");
		} else {
			var act = ds_stack_top(UNDO_STACK);
			if(array_length(act) > 1)
				txt = $"{__txt("Undo")} {array_length(act)} {__txt("Actions")}";
			else 
				txt = $"{__txt("Undo")} {act[0]}";
		}
		
		menus[1][1][0].active = !ds_stack_empty(UNDO_STACK);
		menus[1][1][0].name = txt;
		
		if(ds_stack_empty(REDO_STACK)) {
			txt = __txt("Redo");
		} else {
			var act = ds_stack_top(REDO_STACK);
			if(array_length(act) > 1)
				txt = $"{__txt("Redo")} {array_length(act)} {__txt("Actions")}";
			else 
				txt = $"{__txt("Redo")} {act[0]}";
		}
		
		menus[1][1][1].active = !ds_stack_empty(REDO_STACK);
		menus[1][1][1].name = txt;
	} #endregion
	
	function drawContent(panel) { #region
		var _right     = PREFERENCES.panel_menu_right_control;
		var _draggable = pFOCUS;
		
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		menus[6][1] = STEAM_ENABLED? menu_help_steam : menu_help;
		var hori = w > h;
		
		var xx = ui(40);
		var yy = ui(8);
		
		#region about icon
			if(hori) {
				if(PREFERENCES.panel_menu_right_control)
					xx = ui(24);
				else {
					xx = ui(140);
					draw_set_color(COLORS._main_icon_dark);
					draw_line_round(xx, ui(8), xx, h - ui(8), 3);
				}
		
				var bx = xx;
				if(!PREFERENCES.panel_menu_right_control)
					bx = w - ui(24);
				
				draw_sprite_ui_uniform(THEME.icon_24, 0, bx, h / 2, 1, c_white);
				if(pHOVER && point_in_rectangle(mx, my, bx - ui(16), 0, bx + ui(16), ui(32))) {
					_draggable = false;
					if(mouse_press(mb_left, pFOCUS))
						dialogCall(o_dialog_about);
				}
			} else {
				var bx = ui(20);
				var by = h - ui(20);
			
				draw_sprite_ui_uniform(THEME.icon_24, 0, bx, by, 1, c_white);
				if(pHOVER && point_in_rectangle(mx, my, bx - ui(16), by - ui(16), bx + ui(16), by + ui(16))) {
					_draggable = false;
					if(mouse_press(mb_left, pFOCUS))
						dialogCall(o_dialog_about);
				}
			}
		#endregion
		
		#region menu
			if(hori) {
				if(PREFERENCES.panel_menu_right_control)
					xx += ui(20);
				else
					xx += ui(8);
				yy = 0;
			} else {
				xx = ui(8);
				yy = w < vertical_break? ui(72) : ui(40);
			}
		
			var sx = xx;
			var xc, x0, x1, yc, y0, y1, _mx = xx;
			var row = 1, maxRow = ceil(h / ui(40));
		
			var _ww = 0;
			for(var i = 0; i < array_length(menus) - 1; i++) {
				draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
				var ww = string_width(menus[i][0]) + ui(16 + 8);
				_ww += ww;
				if(_ww > w * 0.4 - sx) {
					row++;
					_ww = 0;
				} 
			}
		
			row = min(row, maxRow);
			var _curRow = 0, currY;
			var _rowH   = (h - ui(12)) / row;
			var _ww     = 0;
		
			for(var i = 0; i < array_length(menus); i++) {
				draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
				var ww = string_width(menus[i][0]) + ui(16);
				var hh = line_get_height() + ui(8);
			
				if(hori) {
					xc = xx + ww / 2;
				
					x0 = xx;
					x1 = xx + ww;
					y0 = ui(6) + _rowH * _curRow;
					y1 = y0 + _rowH;
				
					yc = (y0 + y1) / 2;
					currY = yc;
				} else {
					xc = w / 2;
					yc = yy + hh / 2;
				
					x0 = ui(6);
					x1 = w - ui(6);
					y0 = yy;
					y1 = yy + hh;
				}
			
				if(pHOVER && point_in_rectangle(mx, my, x0, y0, x1, y1)) {
					_draggable = false;
					draw_sprite_stretched(THEME.menu_button, 0, x0, y0, x1 - x0, y1 - y0);
					
					if((mouse_press(mb_left, pFOCUS)) || instance_exists(o_dialog_menubox)) {
						if(hori) menuCall("main_" + menus[i][0] + "_menu", x + x0, y + y1, menus[i][1]);
						else     menuCall("main_" + menus[i][0] + "_menu", x + x1, y + y0, menus[i][1]);
					}
				}
			
				draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
				draw_text_add(xc, yc, menus[i][0]);
			
				if(hori) {
					xx  += ww + 8;
					_mx  = max(_mx, xx);
					_ww += ww + 8;
					if(_ww > w * 0.6 - sx) {
						_curRow++;
						_ww = 0;
						xx  = sx;
					}
				} else
					yy += hh + 8;
			}
		#endregion
		
		#region notification
			var warning_amo = ds_list_size(WARNING);
			var error_amo   = ds_list_size(ERRORS);
			
			if(hori) {
				var nx0 = _mx + ui(24);
				var ny0 = h / 2;
			} else {
				var nx0 = ui(8);
				var ny0 = yy + ui(16);
			}
			
			draw_set_text(f_p0, fa_left, fa_center);
			var wr_w = ui(20) + ui(8) + string_width(string(warning_amo));
			var er_w = ui(20) + ui(8) + string_width(string(error_amo));
			
			if(noti_icon_time > 0) {
				noti_icon_show = lerp_float(noti_icon_show, 1, 4);
				noti_icon_time--;
			} else 
				noti_icon_show = lerp_float(noti_icon_show, 0, 4);
			
			var nw = hori? ui(16) + wr_w + ui(16) + er_w + noti_icon_show * ui(32) : w - ui(16);
			var nh = ui(32);
			
			noti_flash = lerp_linear(noti_flash, 0, 0.02);
			var ev = animation_curve_eval(ac_flash, noti_flash);
			var cc = merge_color(c_white, noti_flash_color, ev);
			
			if(pHOVER && point_in_rectangle(mx, my, nx0, ny0 - nh / 2, nx0 + nw, ny0 + nh / 2)) {
				_draggable = false;
				draw_sprite_stretched_ext(THEME.menu_button, 0, nx0, ny0 - nh / 2, nw, nh, cc, 1);
				if(mouse_press(mb_left, pFOCUS)) {
					var dia = dialogPanelCall(new Panel_Notification(), nx0, ny0 + nh / 2 + ui(4));
					dia.anchor = ANCHOR.left | ANCHOR.top;
				}
				
				TOOLTIP = $"{warning_amo} {__txt("Warnings")} {error_amo} {__txt("Errors")}";
			} else
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, nx0, ny0 - nh / 2, nw, nh, cc, 1);
			
			gpu_set_blendmode(bm_add);
			draw_sprite_stretched_ext(THEME.menu_button_mask, 0, nx0, ny0 - nh / 2, nw, nh, cc, ev / 2);
			gpu_set_blendmode(bm_normal);
			
			if(noti_icon_show > 0)
				draw_sprite_ui(noti_icon, 0, nx0 + nw - ui(16), ny0,,,,, noti_icon_show);
			
			draw_set_color(COLORS._main_text_inner);
			var wr_x = hori? nx0 + ui(8) : w / 2 - (wr_w + er_w + ui(16)) / 2;
			draw_sprite_ui_uniform(THEME.noti_icon_warning, warning_amo? 1 : 0, wr_x + ui(10), ny0);
			draw_text_int(wr_x + ui(28), ny0, warning_amo);
			
			wr_x += wr_w + ui(16);
			draw_sprite_ui_uniform(THEME.noti_icon_error, error_amo? 1 : 0, wr_x + ui(10), ny0);
			draw_text_int(wr_x + ui(28), ny0, error_amo);
			
			if(hori) nx0 += nw + ui(8);
			else	 ny0 += nh + ui(8);
		#endregion
		
		#region addons 
			var wh = ui(32);
			if(!hori) nx0 = ui(8);
			
			if(instance_exists(addon)) {
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
				
				var name = string(instance_number(addon)) + " ";
				var ww = hori? string_width(name) + ui(40) : w - ui(16);
				
				if(pHOVER && point_in_rectangle(mx, my, nx0, ny0 - wh / 2, nx0 + ww, ny0 + wh / 2)) {
					_draggable = false;
					TOOLTIP = __txt("Addons");
					draw_sprite_stretched(THEME.menu_button, 1, nx0, ny0 - wh / 2, ww, wh);
					if(mouse_press(mb_left, pFOCUS))
						dialogPanelCall(new Panel_Addon());
				} else 
					draw_sprite_stretched(THEME.ui_panel_bg, 1, nx0, ny0 - wh / 2, ww, wh);
				draw_text_int(nx0 + ui(8), ny0, name);
				draw_sprite_ui(THEME.addon_icon, 0, nx0 + ui(20) + string_width(name), ny0 + ui(1),,,, COLORS._main_icon);
				
				if(hori) nx0 += ww + ui(4);
				else     ny0 += hh + ui(4);
			}
		#endregion
		
		var x1 = _right? w - ui(6) : ui(8 + 28);
		
		#region actions
			var bs = ui(28);
			
			for( var i = 0, n = array_length(action_buttons); i < n; i++ ) {
				var action = action_buttons[i];
				
				switch(action) {
					case "exit":
						var b = buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pFOCUS, pHOVER,, THEME.window_exit, 0, COLORS._main_accent);
						if(b) _draggable = false;
						if(b == 2) window_close();
						break;
					case "maximize":
						var win_max = window_is_maximized || window_is_fullscreen;
						if(OS == os_macosx)
							win_max = __win_is_maximized;
						
						var b = buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pFOCUS, pHOVER,, THEME.window_maximize, win_max, [ COLORS._main_icon, CDEF.lime ]);
						if(b) _draggable = false;
						if(b == 2) {
							if(OS == os_windows) {
								if(window_is_fullscreen) {
									winMan_setFullscreen(false);
									winMan_Unmaximize();
								} else if(window_is_maximized) {
									winMan_Unmaximize();
									DISPLAY_REFRESH
								} else {
									winMan_Maximize();
									DISPLAY_REFRESH
								}
							} else if(OS == os_macosx) {
								if(__win_is_maximized)  mac_window_minimize();
								else                    mac_window_maximize();
							}
						}
						break;
					case "minimize":
						var b = buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pFOCUS, pHOVER,, THEME.window_minimize, 0, [ COLORS._main_icon, CDEF.yellow ]);
						if(b) _draggable = false;
						if(b == -2) {
							if(OS == os_windows)
								winMan_Minimize();
							else if(OS == os_macosx)
								mac_window_dock();
						}
						break;
					case "fullscreen":
						var win_full = window_is_fullscreen;
						var b = buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pFOCUS, pHOVER,, THEME.window_fullscreen, win_full, [ COLORS._main_icon, CDEF.cyan ]);
						if(b) _draggable = false;
						if(b == 2) {
							if(OS == os_windows)
								winMan_setFullscreen(!win_full);
							else if(OS == os_macosx) {
								if(win_full) {
									winMan_setFullscreen(false);
									mac_window_minimize();
								} else
									winMan_setFullscreen(true);
							}
						}
						break;
				}
				
				if(_right) x1 -= bs + ui(4);
				else       x1 += bs + ui(4);
			}
		#endregion
		
		#region version
			var _xx1 = _right? x1 : w - ui(40);
			
			var txt = "v. " + string(VERSION_STRING);
			if(STEAM_ENABLED) txt += " Steam";
			
			version_name_copy = lerp_float(version_name_copy, 0, 10);
			var tc = merge_color(COLORS._main_text_sub, COLORS._main_value_positive, min(1, version_name_copy));
			var sc = merge_color(c_white, COLORS._main_value_positive, min(1, version_name_copy));
			
			if(hori) {
				draw_set_text(f_p0, fa_center, fa_center, tc);
				var  ww = string_width(txt) + ui(12);
				var _x0 = _xx1 - ww;
				var _y0 = ui(6);
				var _x1 = _xx1;
				var _y1 = h - ui(6);
				
				if(pHOVER && point_in_rectangle(mx, my, _x0, _y0, _x1, _y1)) {
					_draggable = false;
					draw_sprite_stretched_ext(THEME.button_hide_fill, 1, _x0, _y0, _x1 - _x0, _y1 - _y0, sc, 1);
					
					if(mouse_press(mb_left, pFOCUS))
						dialogCall(o_dialog_release_note); 
					if(mouse_press(mb_right, pFOCUS)) {
						clipboard_set_text(VERSION_STRING);
						version_name_copy = 3;
					}
				}
				
				draw_text_int((_x0 + _x1) / 2, (_y0 + _y1) / 2, txt);
			} else {
				var _xx1 = ui(40);
				var y1 = h - ui(20);
				
				draw_set_text(f_p0, fa_left, fa_center, tc);
				var ww = string_width(txt) + ui(12);
				if(pHOVER && point_in_rectangle(mx, my, _xx1, y1 - ui(16), _xx1 + ww, y1 + ui(16))) {
					_draggable = false;
					draw_sprite_stretched_ext(THEME.button_hide_fill, 1, _xx1, y1 - ui(16), ww, ui(32), sc, 1);
					
					if(mouse_press(mb_left, pFOCUS))
						dialogCall(o_dialog_release_note); 
					if(mouse_press(mb_right, pFOCUS)) {
						clipboard_set_text(VERSION_STRING);
						version_name_copy = 3;
					}
				}
				
				draw_text_int(_xx1 + ui(6), y1, txt);
			}
		#endregion
		
		#region title
			var txt = "";
			if(PROJECT.safeMode) txt += $"[{__txt("SAFE MODE")}] ";
			if(PROJECT.readonly) txt += $"[{__txt("READ ONLY")}] ";
			
			txt += PROJECT.path == ""? __txt("Untitled") : filename_name(PROJECT.path);
			if(PROJECT.modified) txt += "*";
			txt += " - Pixel Composer";
			if(DEMO)	txt += " DEMO";
			
			var tx0, tx1, tcx;
			var ty0, ty1;
			var tbx0, tby0;
			var maxW;
			
			if(hori) {
				tx0 = nx0;
				tx1 = w - ui(16);
				ty0 = 0;
				ty1 = h;
				tcx  = (tx0 + tx1) / 2;
			} else {
				tx0 = ui(8);
				tx1 = w < vertical_break? w - ui(16) : w - ui(144);
				ty0 = w < vertical_break? ui(36) : ui(6);
				
				tcx = tx0;
				if(!_right && w >= vertical_break) {
					tx0 = x1 - bs;
					tx1 = w - ui(16);
				}
			}
			
			maxW = abs(tx0 - tx1);
			
			draw_set_font(f_p0b);
			var tc = string_cut(txt, maxW);
			var tw = string_width(tc) + ui(16);
			var th = ui(28);
			
			if(hori) {
				tbx0 = tcx - tw / 2;
				tby0 = ty1 / 2 - ui(14);
			} else {
				tbx0 = tx0;
				tby0 = ty0;
			}
			
			var _b   = buttonInstant(THEME.button_hide_fill, tbx0, tby0, tw, th, [mx, my], pFOCUS, pHOVER);
			var _hov = _b > 0;
			
			if(_b) _draggable = false;
			if(_b == 2) {
				_hov = true;
				var arr = [];
				var tip = [];
				for(var i = 0; i < min(10, ds_list_size(RECENT_FILES)); i++)  {
					var _rec = RECENT_FILES[| i];
					var _dat = RECENT_FILE_DATA[| i];
					array_push(arr, menuItem(_rec, function(_dat) { LOAD_PATH(_dat.name); }));
					array_push(tip, [ method(_dat, _dat.getThumbnail), VALUE_TYPE.surface ]);
				}
				
				var dia = hori? menuCall("title_recent_menu", x + tcx, y + h, arr, fa_center) : menuCall("title_recent_menu", x + w, y + tby0, arr);
				dia.tooltips = tip;
			}
			
			if(hori) {
				draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
				draw_text_int(tcx, (ty0 + ty1) / 2, tc);
			} else {
				draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_text_sub);
				draw_text_int(tx0 + ui(8), tby0 + th / 2, tc);
			}
			
			if(IS_PATREON && PREFERENCES.show_supporter_icon) {
				var _tw = string_width(tc);
				var _th = string_height(tc);
				var _cx, _cy;
				
				if(hori) {
					_cx = tcx + _tw / 2;
					_cy = (ty0 + ty1) / 2 - _th / 2;
				} else {
					_cx = tx0 + ui(8) + _tw;
					_cy = tby0 + th / 2 - _th / 2;
				}
				
				_cx += ui(2);
				_cy += ui(6);
				
				var _ib = COLORS._main_text_sub;
				
				if(pHOVER && point_in_rectangle(mx, my, _cx - 12, _cy - 12, _cx + 12, _cy + 12)) {
					TOOLTIP = __txt("Supporter");
					_ib = COLORS._main_accent;
				}
				
				draw_sprite_ext(s_patreon_supporter, 0, _cx, _cy, 1, 1, 0, _hov? COLORS._main_icon_dark : COLORS.panel_bg_clear, 1);
				draw_sprite_ext(s_patreon_supporter, 1, _cx, _cy, 1, 1, 0, _ib, 1);
			}
		#endregion
		
		#region drag
			if(mouse_press(mb_left, _draggable))
				winMan_initDrag(0b10000);
		#endregion
	} #endregion
}