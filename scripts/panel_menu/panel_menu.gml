function Panel_Menu() : PanelContent() constructor {
	title = "Menu";
	
	noti_flash = 0;
	noti_flash_color = COLORS._main_accent;
	noti_icon = noone;
	noti_icon_show = 0;
	noti_icon_time = 0;
	
	if(PREF_MAP[? "panel_menu_right_control"])
		action_buttons = ["exit", "maximize", "minimize", "fullscreen"];
	else
		action_buttons = ["exit", "minimize", "maximize", "fullscreen"];
	
	menu_file = [
		menuItem(get_text("panel_menu_new", "New"), function() { NEW(); }, THEME.new_file, ["", "New file"]),
		menuItem(get_text("panel_menu_open", "Open") + "...", function() { LOAD(); }, THEME.noti_icon_file_load, ["", "Open"]),
		menuItem(get_text("panel_menu_save", "Save"), function() { SAVE(); }, THEME.save, ["", "Save"]),
		menuItem(get_text("panel_menu_save_as", "Save as..."), function() { SAVE_AS(); }, THEME.save, ["", "Save as"]),
		menuItem(get_text("panel_menu_recent_files", "Recent files"), function(_x, _y, _depth) { 
				var arr = [];
				for(var i = 0; i < min(10, ds_list_size(RECENT_FILES)); i++)  {
					var _rec = RECENT_FILES[| i];
					array_push(arr, menuItem(_rec, function(_x, _y, _depth, _path) { LOAD_PATH(_path); }));
				}
				
				return submenuCall(_x, _y, _depth, arr);
		}).setIsShelf(),
		menuItem(get_text("panel_menu_auto_save_folder", "Open autosave folder"), function() { shellOpenExplorer(DIRECTORY + "autosave"); }, THEME.save_auto),
		-1,
		menuItem(get_text("preferences", "Preferences") + "...", function() { dialogCall(o_dialog_preference); }, THEME.gear),
		menuItem(get_text("panel_menu_splash_screen", "Splash screen"), function() { dialogCall(o_dialog_splash); }),
		-1,
		menuItem(get_text("panel_menu_addons", "Addons"), function(_x, _y, _depth) { 
			return submenuCall(_x, _y, _depth, [
				menuItem(get_text("panel_menu_addons_key", "Key displayer"), function() { 
					if(instance_exists(addon_key_displayer)) {
						instance_destroy(addon_key_displayer);
						return;
					}
						
					instance_create_depth(0, 0, 0, addon_key_displayer);
				}),
			]);
		}, THEME.addon ).setIsShelf(),
		-1,
		menuItem(get_text("fullscreen", "Toggle fullscreen"), function() { 
			if(gameframe_is_fullscreen_window())
				gameframe_set_fullscreen(0);
			else
				gameframe_set_fullscreen(2);
		},, ["", "Fullscreen"]),
		menuItem(get_text("exit", "Close program"), function() { window_close(); }),
	];
	
	if(DEMO) array_delete(menu_file, 1, 4);
	
	menu_help = [
		menuItem(get_text("panel_menu_help_video", "Tutorial videos"), function() {
			url_open("https://www.youtube.com/@makhamdev");
		}, THEME.youtube),
		menuItem(get_text("panel_menu_help_wiki", "Community Wiki"), function() {
			url_open("https://pixel-composer.fandom.com/wiki/Pixel_Composer_Wiki");
		}, THEME.wiki),
		//-1,
		//menuItem(get_text("panel_menu_itch", "itch.io page"), function() {
		//	url_open("https://makham.itch.io/pixel-composer");
		//}, THEME.itch),
		//menuItem(get_text("panel_menu_steam", "Steam page"), function() {
		//	url_open("https://store.steampowered.com/app/2299510/Pixel_Composer");
		//}, THEME.steam),
		-1, 
		menuItem(get_text("panel_menu_directory", "Open local directory"), function() {
			shellOpenExplorer(DIRECTORY);
		}, THEME.folder),
		menuItem(get_text("panel_menu_directory", "Open autosave directory"), function() {
			shellOpenExplorer(DIRECTORY + "autosave/");
		}, THEME.folder),
		menuItem(get_text("panel_menu_reset_default", "Reset default collection, assets"), function() {
			zip_unzip("data/Collections.zip", DIRECTORY + "Collections");
			zip_unzip("data/Assets.zip", DIRECTORY + "Assets");
		}),
	];
	
	menu_help_steam = array_clone(menu_help);
	array_push(menu_help_steam, -1, 
		menuItem(get_text("panel_menu_steam_workshop", "Steam Workshop"), function() {
			steam_activate_overlay_browser("https://steamcommunity.com/app/2299510/workshop/");
		}, THEME.steam) );
	
	menus = [
		[ get_text("panel_menu_file", "File"), menu_file ],
		[ get_text("panel_menu_edit", "Edit"), [
			menuItem(get_text("undo", "Undo"), function() { UNDO(); }, THEME.undo, ["", "Undo"]),
			menuItem(get_text("redo", "Redo"), function() { REDO(); }, THEME.redo, ["", "Redo"]),
			menuItem(get_text("history_title", "Action history"), function() { dialogPanelCall(new Panel_History()); }),
		]],
		[ get_text("panel_menu_preview", "Preview"), [
			menuItem(get_text("panel_menu_center_preview", "Center preview"), function() { PANEL_PREVIEW.do_fullView = true; }, THEME.icon_center_canvas, ["Preview", "Focus content"]), 
			menuItem(get_text("panel_menu_save_current_preview_as", "Save current preview as..."), function() { PANEL_PREVIEW.saveCurrentFrame(); }, noone, ["Preview", "Save current frame"]), 
			menuItemGroup(get_text("panel_menu_preview_background", "Preview background"), [
				[ s_menu_transparent,	function() { PANEL_PREVIEW.canvas_bg = -1; } ],
				[ s_menu_white,			function() { PANEL_PREVIEW.canvas_bg = c_white; } ],
				[ s_menu_black,			function() { PANEL_PREVIEW.canvas_bg = c_black; } ],
			]), 
			-1,
			menuItem(get_text("panel_menu_show_grid", "Show Grid"), function() { PANEL_PREVIEW.grid_show = !PANEL_PREVIEW.grid_show; }, [ THEME.icon_grid, 1 ], ["Preview", "Toggle grid"]),
			menuItem(get_text("panel_menu_grid_setting", "Grid setting..."), function() { 
				var dia = dialogCall(o_dialog_preview_grid); 
				dia.anchor = ANCHOR.none;
			}, THEME.icon_grid_setting),
		]], 
		[ get_text("panel_menu_animation", "Animation"), [
			menuItem(get_text("panel_menu_animation_setting", "Animation setting..."), function() { 
				var dia = dialogCall(o_dialog_animation); 
				dia.anchor = ANCHOR.none;
			}, THEME.animation_setting),
			-1,
			menuItem(get_text("panel_menu_animation_scaler", "Animation scaler..."), function() { 
				dialogCall(o_dialog_anim_time_scaler); 
			}, THEME.animation_timing),
		]],
		[ get_text("panel_menu_rendering", "Rendering"), [
			menuItem(get_text("panel_menu_render_all_nodes", "Render all nodes"), function() { 
				for(var i = 0; i < ds_list_size(NODES); i++) 
					NODES[| i].triggerRender();
				UPDATE |= RENDER_TYPE.full; 
			}, [ THEME.sequence_control, 1 ], ["", "Render all"]),
			menuItem(get_text("panel_menu_execute_exports", "Execute all export nodes"), function() { 
				var key = ds_map_find_first(NODE_MAP);
				repeat(ds_map_size(NODE_MAP)) {
					var node = NODE_MAP[? key];
					key = ds_map_find_next(NODE_MAP, key);
					
					if(!node.active) continue;
					if(instanceof(node) != "Node_Export") continue;
					
					node.doInspectorAction();
				}
			}),
		]],
		[ get_text("panel_menu_panels", "Panels"), [
			menuItem(get_text("panel_menu_workspace", "Workspace"), function(_x, _y, _depth) { 
				var arr = [], lays = [];
				var f   = file_find_first(DIRECTORY + "layouts/*", 0);
				while(f != "") {
					array_push(lays, filename_name_only(f));
					f = file_find_next();
				}
				
				array_push(arr, menuItem("Save layout", function() {
					var dia = dialogCall(o_dialog_file_name, mouse_mx + ui(8), mouse_my + ui(8));
					dia.onModify = function(name) { 
						var cont = panelSerialize();
						json_save_struct(DIRECTORY + "layouts/" + name + ".json", cont);
					};
				}));
				array_push(arr, -1);
				
				for(var i = 0; i < array_length(lays); i++)  {
					array_push(arr, menuItem(lays[i], 
						function(_x, _y, _depth, _path) { 
							PREF_MAP[? "panel_layout_file"] = _path;
							PREF_SAVE();
							setPanel();
						}));
				}
				
				return submenuCall(_x, _y, _depth, arr);
			}).setIsShelf(),
			-1,
			menuItem(get_text("panel_menu_collections", "Collections"), function() {
				PREF_MAP[? "panel_collection"] = !PREF_MAP[? "panel_collection"];
				resetPanel();
				PREF_SAVE();
			},,, function() { return findPanel("Panel_Collection") != noone; } ),
			menuItem(get_text("panel_menu_graph", "Graph"),			function() { panelAdd("Panel_Graph") },,,		function() { return findPanel("Panel_Graph") != noone; } ),
			menuItem(get_text("panel_menu_preview", "Preview"),		function() { panelAdd("Panel_Preview") },,,		function() { return findPanel("Panel_Preview") != noone; } ),
			menuItem(get_text("panel_menu_inspector", "Inspector"), function() { panelAdd("Panel_Inspector") },,,	function() { return findPanel("Panel_Inspector") != noone; } ),
			menuItem(get_text("panel_menu_workspace", "Workspace"), function() { panelAdd("Panel_Workspace") },,,	function() { return findPanel("Panel_Workspace") != noone; } ),
			menuItem(get_text("panel_menu_animation", "Animation"), function() { panelAdd("Panel_Animation") },,,	function() { return findPanel("Panel_Animation") != noone; } ),
			menuItem(get_text("tunnels", "Tunnels"), function() {
				dialogPanelCall(new Panel_Tunnels());
			},, ["Graph", "Tunnels"]),
		]],
		[ get_text("panel_menu_help", "Help"), menu_help ],
	]
	
	if(TESTING) {
		array_push(menus, [ get_text("panel_menu_test", "Test"), [
			menuItem(get_text("panel_menu_test_load_all", "Load all current collections"), function() { 
				__test_load_current_collections();
			}),
			menuItem(get_text("panel_menu_test_update_all", "Update all current collections"), function() { 
				__test_update_current_collections();
			}),
			menuItem(get_text("panel_menu_test_add_meta", "Add metadata to current collections"), function() { 
				__test_metadata_current_collections();
			}),
			menuItem(get_text("panel_menu_test_update_sam", "Update sample projects"), function() { 
				__test_update_sample_projects();
			}),
			-1,
			menuItem(get_text("panel_menu_test_load_nodes", "Load all nodes"), function() { 
				__test_load_all_nodes();
			}),
			menuItem(get_text("panel_menu_test_gen_guide", "Generate node guide"), function() { 
				__generate_node_data();
			}),
			-1,
			menuItem(get_text("panel_menu_test_crash", "Force crash"), function() { 
				print(1 + "a");
			}),
		]]);
	}
	
	function setNotiIcon(icon) {
		noti_icon = icon;
		noti_icon_time = 90;
	}
	
	function undoUpdate() {
		var txt;
		
		if(ds_stack_empty(UNDO_STACK)) {
			txt = get_text("undo", "Undo");
		} else {
			var act = ds_stack_top(UNDO_STACK);
			if(array_length(act) > 1)
				txt = get_text("undo", "Undo") + " " + string(array_length(act)) + " " + get_text("actions", "Actions");
			else 
				txt = get_text("undo", "Undo") + " " + act[0].toString();
		}
		
		menus[1][1][0].active = !ds_stack_empty(UNDO_STACK);
		menus[1][1][0].name = txt;
		
		if(ds_stack_empty(REDO_STACK)) {
			txt = get_text("redo", "Redo");
		} else {
			var act = ds_stack_top(REDO_STACK);
			if(array_length(act) > 1)
				txt = get_text("redo", "Redo") + " " + string(array_length(act)) + " " + get_text("actions", "Actions");
			else 
				txt = get_text("redo", "Redo") + " " + act[0].toString();
		}
		
		menus[1][1][1].active = !ds_stack_empty(REDO_STACK);
		menus[1][1][1].name = txt;
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		menus[6][1] = STEAM_ENABLED? menu_help_steam : menu_help;
		var hori = w > h;
		
		var xx = ui(40);
		var yy = ui(8);
		
		if(hori) {
			if(PREF_MAP[? "panel_menu_right_control"])
				xx = ui(24);
			else {
				xx = ui(140);
				draw_set_color(COLORS._main_icon_dark);
				draw_line_round(xx, ui(8), xx, h - ui(8), 3);
			}
		
			var bx = xx;
			if(!PREF_MAP[? "panel_menu_right_control"])
				bx = w - ui(24);
		
			draw_sprite_ui_uniform(THEME.icon_24, 0, bx, h / 2, 1, c_white);
			if(pHOVER && point_in_rectangle(mx, my, bx - ui(16), 0, bx + ui(16), ui(32))) {
				if(mouse_press(mb_left, pFOCUS))
					dialogCall(o_dialog_about);
			}
		} else {
			var bx = ui(20);
			var by = h - ui(20);
			
			draw_sprite_ui_uniform(THEME.icon_24, 0, bx, by, 1, c_white);
			if(pHOVER && point_in_rectangle(mx, my, bx - ui(16), by - ui(16), bx + ui(16), by + ui(16))) {
				if(mouse_press(mb_left, pFOCUS))
					dialogCall(o_dialog_about);
			}
		}
		
		if(hori) {
			if(PREF_MAP[? "panel_menu_right_control"])
				xx += ui(20);
			else
				xx += ui(8);
			yy = 0;
		} else {
			xx = ui(8);
			yy = w < ui(200)? ui(72) : ui(40);
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
			var hh = line_height() + ui(8);
			
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
				draw_sprite_stretched(THEME.menu_button, 0, x0, y0, x1 - x0, y1 - y0);
					
				if((mouse_press(mb_left, pFOCUS)) || instance_exists(o_dialog_menubox)) {
					if(hori) menuCall( x + x0, y + y1, menus[i][1]);
					else     menuCall( x + x1, y + y0, menus[i][1]);
				}
			}
			
			draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
			draw_text_add(xc, yc, menus[i][0]);
			
			if(hori) {
				xx  += ww + 8;
				_mx  = max(_mx, xx);
				_ww += ww + 8;
				if(_ww > w * 0.4 - sx) {
					_curRow++;
					_ww = 0;
					xx  = sx;
				}
			} else     yy += hh + 8;
		}
		
		#region notification
			var warning_amo = 0;
			for( var i = 0; i < ds_list_size(WARNING); i++ )
				warning_amo += WARNING[| i].amount;
			
			var error_amo = 0;
			for( var i = 0; i < ds_list_size(ERRORS); i++ )
				error_amo += ERRORS[| i].amount;
			
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
				draw_sprite_stretched_ext(THEME.menu_button, 0, nx0, ny0 - nh / 2, nw, nh, cc, 1);
				if(mouse_press(mb_left, pFOCUS)) {
					var dia = dialogPanelCall(new Panel_Notification(), nx0, ny0 + nh / 2 + ui(4));
					dia.anchor = ANCHOR.left | ANCHOR.top;
				}
				
				TOOLTIP = string(warning_amo) + " " + get_text("warning", "Warnings") + " " + string(error_amo) + " " + get_text("errors", "Errors");
			} else
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, nx0, ny0 - nh / 2, nw, nh, cc, 1);
			
			gpu_set_blendmode(bm_add);
			draw_sprite_stretched_ext(THEME.menu_button_mask, 0, nx0, ny0 - nh / 2, nw, nh, cc, ev / 2);
			gpu_set_blendmode(bm_normal);
			
			if(noti_icon_show > 0)
				draw_sprite_ui(noti_icon, 0, nx0 + nw - ui(16), ny0,,,,, noti_icon_show);
				
			var wr_x = hori? nx0 + ui(8) : w / 2 - (wr_w + er_w + ui(16)) / 2;
			draw_sprite_ui_uniform(THEME.noti_icon_warning, warning_amo? 1 : 0, wr_x + ui(10), ny0);
			draw_text(wr_x + ui(28), ny0, warning_amo);
			
			wr_x += wr_w + ui(16);
			draw_sprite_ui_uniform(THEME.noti_icon_error, error_amo? 1 : 0, wr_x + ui(10), ny0);
			draw_text(wr_x + ui(28), ny0, error_amo);
			
			if(hori) nx0 += nw + ui(8);
			else	 ny0 += nh + ui(8);
		#endregion
		
		#region addons 
			var wh = ui(32);
			if(!hori) nx0 = ui(8);
			
			with(addon) {
				draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
				var ww = hori? string_width(name) + ui(16) : w - ui(16);
				
				if(other.pHOVER && point_in_rectangle(other.mx, other.my, nx0, ny0 - wh / 2, nx0 + ww, ny0 + wh / 2)) {
					draw_sprite_stretched(THEME.menu_button, 1, nx0, ny0 - wh / 2, ww, wh);
					if(mouse_press(mb_left, other.pFOCUS)) 
						instance_destroy();
					if(mouse_press(mb_right, other.pFOCUS)) 
						menuCall(,, menu);
				} else 
					draw_sprite_stretched(THEME.ui_panel_bg, 1, nx0, ny0 - wh / 2, ww, wh);
				draw_text(nx0 + ww / 2, ny0, name);
				
				if(hori) nx0 += ww + ui(4);
				else     ny0 += hh + ui(4);
			}
		#endregion
		
		var x1 = w - ui(6);
		if(PREF_MAP[? "panel_menu_right_control"])
			x1 = w - ui(6);
		else
			x1 = ui(8 + 28);
		
		#region actions
			var bs = ui(28);
			
			for( var i = 0; i < array_length(action_buttons); i++ ) {
				var action = action_buttons[i];
				
				switch(action) {
					case "exit":
						if(buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pFOCUS, pHOVER,, THEME.window_exit, 0, COLORS._main_accent) == 2)
							window_close();
						break;
					case "maximize":
						var win_max = gameframe_is_maximized() || gameframe_is_fullscreen_window();
						if(OS == os_macosx)
							win_max = __win_is_maximized;
						
						if(buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pFOCUS, pHOVER,, THEME.window_maximize, win_max, [ COLORS._main_icon, CDEF.lime ]) == 2) {
							if(OS == os_windows) {
								if(gameframe_is_fullscreen_window()) {
									gameframe_set_fullscreen(0);
									gameframe_restore();
								} else if(gameframe_is_maximized())
									gameframe_restore();
								else
									gameframe_maximize();
							} else if(OS == os_macosx) {
								if(__win_is_maximized)  mac_window_minimize();
								else                    mac_window_maximize();
							}
						}
						break;
					case "minimize":
						if(OS == os_windows)
						if(buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pFOCUS, pHOVER,, THEME.window_minimize, 0, [ COLORS._main_icon, CDEF.yellow ]) == -2) {
							if(OS == os_windows)
								gameframe_minimize();
							else if(OS == os_macosx) {
								
							}
						}
						
						if(OS == os_macosx) {
							buttonInstant(THEME.button_hide, x1 - bs, ui(6), bs, bs, [mx, my], pFOCUS, pHOVER,, THEME.window_minimize, 0, [ COLORS._main_icon, COLORS._main_icon ]);
						}
						break;
					case "fullscreen":
						var win_full = OS == os_windows? gameframe_is_fullscreen_window() : window_get_fullscreen();
						if(buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pFOCUS, pHOVER,, THEME.window_fullscreen, win_full, [ COLORS._main_icon, CDEF.cyan ]) == 2) {
							if(OS == os_windows)
								gameframe_set_fullscreen(gameframe_is_fullscreen_window()? 0 : 2);
							else if(OS == os_macosx) {
								if(window_get_fullscreen()) {
									window_set_fullscreen(false);
									mac_window_minimize();
								} else
									window_set_fullscreen(true);
							}
						}
						break;
				}
				
				if(PREF_MAP[? "panel_menu_right_control"])
					x1 -= bs + ui(4);
				else 
					x1 += bs + ui(4);
			}
		#endregion
		
		if(!PREF_MAP[? "panel_menu_right_control"])	x1 = w - ui(40);
		
		#region version
			var txt = "v. " + string(VERSION_STRING);
			if(STEAM_ENABLED) txt += " Steam";
			
			if(hori) {
				draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text_sub);
				var ww = string_width(txt) + ui(12);
				
				if(h > ui(76)) {
					ww += ui(16);
					var _x0 = w - ui(8) - ww;
					var _y0 = h - ui(40);
					var _x1 = w - ui(8);
					var _y1 = h - ui(8);
				} else {
					var _x0 = x1 - ww;
					var _y0 = ui(6);
					var _x1 = x1;
					var _y1 = h - ui(6);
				}
				
				if(pHOVER && point_in_rectangle(mx, my, _x0, _y0, _x1, _y1)) {
					draw_sprite_stretched(THEME.button_hide_fill, 1, _x0, _y0, _x1 - _x0, _y1 - _y0);
			
					if(mouse_press(mb_left, pFOCUS)) {
						dialogCall(o_dialog_release_note); 
					}
				}
				draw_text((_x0 + _x1) / 2, (_y0 + _y1) / 2, txt);
			} else {
				var x1 = ui(40);
				var y1 = h - ui(20);
				
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
				var ww = string_width(txt) + ui(12);
				if(pHOVER && point_in_rectangle(mx, my, x1, y1 - ui(16), x1 + ww, y1 + ui(16))) {
					draw_sprite_stretched(THEME.button_hide_fill, 1, x1, y1 - ui(16), ww, ui(32));
					
					if(mouse_press(mb_left, pFOCUS))
						dialogCall(o_dialog_release_note); 
				}
				draw_text(x1 + ui(6), y1, txt);
			}
		#endregion
		
		#region title
			var txt = "";
			if(CURRENT_PATH == "") 
				txt = "Untitled";
			else 
				txt = filename_name(CURRENT_PATH);
			if(MODIFIED)
				txt += "*";
			txt += " - Pixel Composer";
			if(DEMO) txt += " DEMO";
			
			var tx0, tx1, maxW, tcx;
			var ty0, ty1;
			var tbx0, tby0;
			
			if(hori) {
				if(h > ui(76)) {
					tx0 = nx0;
					tx1 = w - ui(8);
					ty0 = 0;
					ty1 = h;
				} else {
					tx0 = nx0;
					tx1 = x1 - ww;
					ty0 = 0;
					ty1 = h;
				}
				
				tcx  = (tx0 + tx1) / 2;
			} else {
				tx0 = ui(8);
				tx1 = w < ui(200)? w - ui(16) : w - ui(144);
				ty0 = w < ui(200)? ui(36) : ui(6);
				
				tcx  = tx0;
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
			
			if(buttonInstant(THEME.button_hide_fill, tbx0, tby0, tw, th, [mx, my], pFOCUS, pHOVER) == 2) {
				var arr = [];
				var tip = [];
				for(var i = 0; i < min(10, ds_list_size(RECENT_FILES)); i++)  {
					var _rec = RECENT_FILES[| i];
					var _dat = RECENT_FILE_DATA[| i];
					array_push(arr, menuItem(_rec, function(_x, _y, _depth, _path) { LOAD_PATH(_path); }));
					array_push(tip, [ method(_dat, _dat.getThumbnail), VALUE_TYPE.surface ]);
				}
				
				var dia = hori? menuCall(x + tcx, y + h, arr, fa_center) : menuCall(x + w, y + tby0, arr);
				dia.tooltips = tip;
			}
			
			if(hori) {
				draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
				draw_text(tcx, (ty0 + ty1) / 2, tc);
			} else {
				draw_set_text(f_p0b, fa_left, fa_center, COLORS._main_text_sub);
				draw_text(tx0 + ui(8), tby0 + th / 2, tc);
			}
		#endregion
			
		undoUpdate();
	}
}