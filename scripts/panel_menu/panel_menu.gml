function Panel_Menu() : PanelContent() constructor {
	draggable  = false;
	
	noti_flash = 0;
	noti_flash_color = COLORS._main_accent;
	noti_icon = noone;
	noti_icon_show = 0;
	noti_icon_time = 0;
	
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
			shellOpenExplorer(DIRECTORY + "autosave\\");
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
			menuItem(get_text("history_title", "Action history"), function() { dialogCall(o_dialog_history, mouse_mx, mouse_my); }),
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
			menuItemGroup(get_text("panel_menu_workspace", "Workspace"), [
				[ THEME.workspace_horizontal, function() { clearPanel(); PREF_MAP[? "panel_layout"] = 0; setPanel(); PREF_SAVE(); } ],
				[ THEME.workspace_vertical, function() { clearPanel(); PREF_MAP[? "panel_layout"] = 1; setPanel(); PREF_SAVE(); } ]
			]),
			-1,
			menuItem(get_text("panel_menu_collections", "Collections"), function() {
				clearPanel();
				PREF_MAP[? "panel_collection"] = !PREF_MAP[? "panel_collection"];
				setPanel();
				PREF_SAVE();
			}),
			menuItem(get_text("tunnels", "Tunnels"), function() {
				dialogCall(o_dialog_tunnels);
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
		draw_sprite_ui_uniform(THEME.icon_24, 0, h / 2, h / 2, 1, c_white);
		var xx = h;
		
		menus[6][1] = STEAM_ENABLED? menu_help_steam : menu_help;
		
		if(pHOVER && point_in_rectangle(mx, my, 0, 0, ui(40), ui(32))) {
			if(mouse_press(mb_left, pFOCUS))
				dialogCall(o_dialog_about);
		}
		
		for(var i = 0; i < array_length(menus); i++) {
			draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
			var ww = string_width(menus[i][0]) + ui(16);
			var xc = xx + ww / 2;
			
			if(pHOVER && point_in_rectangle(mx, my, xc - ww / 2, 0, xc + ww / 2, h)) {
				draw_sprite_stretched(THEME.menu_button, 0, xc - ww / 2, ui(6), ww, h - ui(12));
					
				if((mouse_press(mb_left, pFOCUS)) || instance_exists(o_dialog_menubox)) {
					menuCall( xx, h, menus[i][1]);
				}
			}
			
			draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
			draw_text_over(xx + ww / 2, h / 2, menus[i][0]);
			
			xx += ww + 8;
		}
		
		#region notification
			var warning_amo = 0;
			for( var i = 0; i < ds_list_size(WARNING); i++ )
				warning_amo += WARNING[| i].amount;
			
			var error_amo = 0;
			for( var i = 0; i < ds_list_size(ERRORS); i++ )
				error_amo += ERRORS[| i].amount;
			
			var nx0 = xx + ui(24);
			var ny0 = h / 2;
			
			draw_set_text(f_p0, fa_left, fa_center);
			var wr_w = ui(20) + ui(8) + string_width(string(warning_amo));
			var er_w = ui(20) + ui(8) + string_width(string(error_amo));
			
			if(noti_icon_time > 0) {
				noti_icon_show = lerp_float(noti_icon_show, 1, 4);
				noti_icon_time--;
			} else 
				noti_icon_show = lerp_float(noti_icon_show, 0, 4);
			
			var nw = ui(16) + wr_w + ui(16) + er_w + noti_icon_show * ui(32);
			var nh = ui(32);
			
			noti_flash = lerp_linear(noti_flash, 0, 0.02);
			var ev = animation_curve_eval(ac_flash, noti_flash);
			var cc = merge_color(c_white, noti_flash_color, ev);
			
			if(pHOVER && point_in_rectangle(mx, my, nx0, ny0 - nh / 2, nx0 + nw, ny0 + nh / 2)) {
				draw_sprite_stretched_ext(THEME.menu_button, 0, nx0, ny0 - nh / 2, nw, nh, cc, 1);
				if(mouse_press(mb_left, pFOCUS)) {
					var dia = dialogCall(o_dialog_notifications, nx0, ny0 + nh / 2 + ui(4));
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
				
			var wr_x = nx0 + ui(8);
			draw_sprite_ui_uniform(THEME.noti_icon_warning, warning_amo? 1 : 0, wr_x + ui(10), ny0);
			draw_text(wr_x + ui(28), ny0, warning_amo);
			
			var er_x = nx0 + ui(8) + wr_w + ui(16);
			draw_sprite_ui_uniform(THEME.noti_icon_error, error_amo? 1 : 0, er_x + ui(10), ny0);
			draw_text(er_x + ui(28), ny0, error_amo);
			
			nx0 += nw + ui(8);
		#endregion
		
		#region addons 
			var wh = ui(32);
			
			with(addon) {
				draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
				var ww = string_width(name) + ui(16);
				
				if(other.pHOVER && point_in_rectangle(other.mx, other.my, nx0, ny0 - wh / 2, nx0 + ww, ny0 + wh / 2)) {
					draw_sprite_stretched(THEME.menu_button, 1, nx0, ny0 - wh / 2, ww, wh);
					if(mouse_press(mb_left, other.pFOCUS)) 
						instance_destroy();
					if(mouse_press(mb_right, other.pFOCUS)) 
						menuCall(,, menu);
				} else 
					draw_sprite_stretched(THEME.ui_panel_bg, 1, nx0, ny0 - wh / 2, ww, wh);
				draw_text(nx0 + ww / 2, ny0, name);
				
				nx0 += ww + ui(4);
			}
		#endregion
		
		var x1 = w - ui(6);
		
		#region actions
			var bs = ui(28);
			
			if(buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pFOCUS, pHOVER,, THEME.window_exit, 0, COLORS._main_accent) == 2) {
				window_close();
			}
			x1 -= bs + ui(4);
			
			var win_max = gameframe_is_maximized() || gameframe_is_fullscreen_window();
			if(buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pFOCUS, pHOVER,, THEME.window_maximize, win_max, [ COLORS._main_icon, CDEF.lime ]) == 2) {
				if(gameframe_is_fullscreen_window()) {
					gameframe_set_fullscreen(0);
					gameframe_restore();
				} else if(gameframe_is_maximized())
					gameframe_restore();
				else
					gameframe_maximize();
			}
			x1 -= bs + ui(4);
			  
			if(buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pFOCUS, pHOVER,, THEME.window_minimize, 0, [ COLORS._main_icon, CDEF.yellow ]) == -2) {
				gameframe_minimize();
			}
			x1 -= bs + ui(4);
			
			if(buttonInstant(THEME.button_hide_fill, x1 - bs, ui(6), bs, bs, [mx, my], pFOCUS, pHOVER,, THEME.window_fullscreen, gameframe_is_fullscreen_window(), [ COLORS._main_icon, CDEF.cyan ]) == 2) {
				if(gameframe_is_fullscreen_window())
					gameframe_set_fullscreen(0);
				else
					gameframe_set_fullscreen(2);
			}
			x1 -= bs + ui(4);
		#endregion
		
		#region version
			draw_set_text(f_p0, fa_right, fa_center, COLORS._main_text_sub);
			var txt = "v. " + string(VERSION_STRING);
			if(STEAM_ENABLED) txt += " Steam";
			var ww = string_width(txt) + ui(12);
			if(pHOVER && point_in_rectangle(mx, my, x1 - ww, 0, x1, h)) {
				draw_sprite_stretched(THEME.button_hide_fill, 1, x1 - ww, ui(6), ww, h - ui(12));
			
				if(mouse_press(mb_left, pFOCUS)) {
					dialogCall(o_dialog_release_note); 
				}
			}
			draw_text(x1 - ui(6), h / 2, txt);
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
			
			var tx0  = nx0;
			var tx1  = x1 - ww;
			var maxW = abs(tx0 - tx1);
			var tcx  = (tx0 + tx1) / 2;
			
			draw_set_font(f_p0b);
			var tc = string_cut(txt, maxW);
			var tw = string_width(tc) + ui(16);
			
			if(buttonInstant(THEME.button_hide_fill, tcx - tw / 2, h / 2 - ui(14), tw, ui(28), [mx, my], pFOCUS, pHOVER) == 2) {
				var arr = [];
				var tip = [];
				for(var i = 0; i < min(10, ds_list_size(RECENT_FILES)); i++)  {
					var _rec = RECENT_FILES[| i];
					var _dat = RECENT_FILE_DATA[| i];
					array_push(arr, menuItem(_rec, function(_x, _y, _depth, _path) { LOAD_PATH(_path); }));
					array_push(tip, [ method(_dat, _dat.getThumbnail), VALUE_TYPE.surface ]);
				}
				
				var dia = menuCall(tcx, h, arr, fa_center);
				dia.tooltips = tip;
			}
			
			draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_sub);
			draw_text(tcx, h / 2, tc);
		#endregion
			
		undoUpdate();
	}
}