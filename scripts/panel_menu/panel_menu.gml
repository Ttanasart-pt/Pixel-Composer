function Panel_Menu() : PanelContent() constructor {
	draggable  = false;
	
	noti_flash = 0;
	noti_flash_color = COLORS._main_accent;
	noti_icon = noone;
	noti_icon_show = 0;
	noti_icon_time = 0;
	
	menu_file = [
		[ get_text("panel_menu_new", "New"), function() { 
			NEW();
		}, ["", "New file"] ],
		[ get_text("panel_menu_open", "Open") + "...", function() { LOAD(); }, ["", "Open"]  ],
		[ get_text("panel_menu_save", "Save"), function() { SAVE(); }, ["", "Save"]  ],
		[ get_text("panel_menu_save_as", "Save as..."), function() { SAVE_AS(); }, ["", "Save as"]  ],
		[ get_text("panel_menu_recent_files", "Recent files"), function(_x, _y, _depth) { 
				var dia = instance_create_depth(_x - ui(4), _y, _depth - 1, o_dialog_menubox);
				var arr = [];
				for(var i = 0; i < min(10, ds_list_size(RECENT_FILES)); i++)  {
					var _rec = RECENT_FILES[| i];
					array_push(arr, [ _rec, function(_x, _y, _depth, _path) { LOAD_PATH(_path); } ]);
				}
				dia.setMenu(arr);
				return dia;
		}, ">" ],
		-1,
		[ get_text("preferences", "Preferences") + "...", function() { dialogCall(o_dialog_preference); } ],
		[ get_text("panel_menu_splash_screen", "Splash screen"), function() { dialogCall(o_dialog_splash); } ],
		-1,
		[ get_text("panel_menu_addons", "Addons"), function(_x, _y, _depth) { 
				var dia = instance_create_depth(_x - ui(4), _y, _depth - 1, o_dialog_menubox);
				dia.setMenu([
					[ get_text("panel_menu_addons_key", "Key displayer"), function() { 
						if(instance_exists(addon_key_displayer)) {
							instance_destroy(addon_key_displayer);
							return;
						}
						
						instance_create_depth(0, 0, 0, addon_key_displayer);
					}]
				]);
				return dia;
		}, ">" ],
	];
	
	if(DEMO) {
		array_delete(menu_file, 1, 4);
	}
	
	menu_help = [ get_text("panel_menu_help", "Help"), [
		[ get_text("panel_menu_help_video", "Tutorial videos"), function() {
			url_open("https://www.youtube.com/@makhamdev");
		} ],
		[ get_text("panel_menu_help_wiki", "Community Wiki"), function() {
			url_open("https://pixel-composer.fandom.com/wiki/Pixel_Composer_Wiki");
		} ],
		-1,
		[ get_text("panel_menu_itch", "itch.io page"), function() {
			url_open("https://makham.itch.io/pixel-composer");
		} ],
		[ get_text("panel_menu_steam", "Steam page"), function() {
			url_open("https://store.steampowered.com/app/2299510/Pixel_Composer");
		} ],
		-1, 
		[ get_text("panel_menu_directory", "Open local directory"), function() {
			shellOpenExplorer(DIRECTORY);
		} ],
		[ get_text("panel_menu_reset_default", "Reset default collection, assets"), function() {
			zip_unzip("data/Collections.zip", DIRECTORY + "Collections");
			zip_unzip("data/Assets.zip", DIRECTORY + "Assets");
		} ],
	]];
	
	menu_help_steam = array_clone(menu_help);
	array_push(menu_help_steam[1], -1, 
		[ get_text("panel_menu_steam_workshop", "Steam Workshop"), function() {
			steam_activate_overlay_browser("https://steamcommunity.com/app/2299510/workshop/");
		} ]);
	
	menus = [
		[ get_text("panel_menu_file", "File"), menu_file],
		[ get_text("panel_menu_edit", "Edit"), [
			[ get_text("undo", "Undo"), function() { UNDO(); }, ["", "Undo"]  ],
			[ get_text("redo", "Redo"), function() { REDO(); }, ["", "Redo"]  ],
			[ get_text("history_title", "Action history"), function() { dialogCall(o_dialog_history, mouse_mx, mouse_my);  } ],
		]],
		[ get_text("panel_menu_preview", "Preview"), [
			[ get_text("panel_menu_center_preview", "Center preview"), function() { PANEL_PREVIEW.do_fullView = true; }, ["Preview", "Focus content"] ], 
			[ get_text("panel_menu_save_current_preview_as", "Save current preview as..."), function() { PANEL_PREVIEW.saveCurrentFrame(); }, ["Preview", "Save current frame"] ], 
			[ get_text("panel_menu_preview_background", "Preview background"), [
				[ s_menu_transparent,	function() { PANEL_PREVIEW.canvas_bg = -1; } ],
				[ s_menu_white,			function() { PANEL_PREVIEW.canvas_bg = c_white; } ],
				[ s_menu_black,			function() { PANEL_PREVIEW.canvas_bg = c_black; } ],
			]], 
			-1,
			[ get_text("panel_menu_show_grid", "Show Grid"), function() { PANEL_PREVIEW.grid_show = !PANEL_PREVIEW.grid_show; }, ["Preview", "Toggle grid"] ],
			[ get_text("panel_menu_grid_setting", "Grid setting..."), function() { 
				var dia = dialogCall(o_dialog_preview_grid); 
				dia.anchor = ANCHOR.none;
			} ],
		]], 
		[ get_text("panel_menu_animation", "Animation"), [
			[ get_text("panel_menu_animation_setting", "Animation setting..."), function() { 
				var dia = dialogCall(o_dialog_animation); 
				dia.anchor = ANCHOR.none;
			} ],
			-1,
			[ get_text("panel_menu_animation_scaler", "Animation scaler..."), function() { 
				dialogCall(o_dialog_anim_time_scaler); 
			} ],
		]],
		[ get_text("panel_menu_rendering", "Rendering"), [
			[ get_text("panel_menu_render_all_nodes", "Render all nodes"), function() { 
				for(var i = 0; i < ds_list_size(NODES); i++) 
					NODES[| i].triggerRender();
				UPDATE |= RENDER_TYPE.full; 
			}, ["", "Render all"] ],
			[ get_text("panel_menu_execute_exports", "Execute all export nodes"), function() { 
				var key = ds_map_find_first(NODE_MAP);
				repeat(ds_map_size(NODE_MAP)) {
					var node = NODE_MAP[? key];
					key = ds_map_find_next(NODE_MAP, key);
			
					if(!node.active) continue;
					if(instanceof(node) != "Node_Export") continue;
					
					node.initExport();
				}
			}, ],
		]],
		[ get_text("panel_menu_panels", "Panels"), [
			[ get_text("panel_menu_workspace", "Workspace"), [
				[ THEME.workspace_horizontal, function() { clearPanel(); PREF_MAP[? "panel_layout"] = 0; setPanel(); PREF_SAVE(); } ],
				[ THEME.workspace_vertical, function() { clearPanel(); PREF_MAP[? "panel_layout"] = 1; setPanel(); PREF_SAVE(); } ]
			]],
			-1,
			[ get_text("panel_menu_collections", "Collections"), function() {
				clearPanel();
				PREF_MAP[? "panel_collection"] = !PREF_MAP[? "panel_collection"];
				setPanel();
				PREF_SAVE();
			} ],
		]],
		menu_help,
	]
	
	if(TESTING) {
		array_push(menus, [ get_text("panel_menu_test", "Test"), [
			[ get_text("panel_menu_test_load_all", "Load all current collections"), function() { 
				__test_load_current_collections();
			}],
			[ get_text("panel_menu_test_update_all", "Update all current collections"), function() { 
				__test_update_current_collections();
			}],
			[ get_text("panel_menu_test_add_meta", "Add metadata to current collections"), function() { 
				__test_metadata_current_collections();
			}],
			[ get_text("panel_menu_test_update_sam", "Update sample projects"), function() { 
				__test_update_sample_projects();
			}],
			-1,
			[ get_text("panel_menu_test_load_nodes", "Load all nodes"), function() { 
				__test_load_all_nodes();
			}],
			[ get_text("panel_menu_test_gen_guide", "Generate node guide"), function() { 
				__generate_node_guide();
			}],
			-1,
			[ get_text("panel_menu_test_crash", "Force crash"), function() { 
				print(1 + "a");
			}],
		]]);
	}
	
	function setNotiIcon(icon) {
		noti_icon = icon;
		noti_icon_time = 90;
	}
	
	function displayNewVersion() {
		var xx = w - ui(88);
		draw_set_text(f_p0b, fa_right, fa_center, COLORS._main_value_positive);
		var txt = " " + get_text("panel_menu_newer", "panel_menu_newer") + " ";
		var ww = string_width(txt);
			
		if(pHOVER && point_in_rectangle(mx, my, xx - ww, 0, xx, h)) {
			draw_sprite_stretched(THEME.menu_button, 0, xx - ww - ui(6), ui(6), ww + ui(12), h - ui(12));
				
			if(mouse_press(mb_left, pFOCUS)) {
				url_open("https://makham.itch.io/pixel-composer");
			}
		}
			
		draw_text(xx, h / 2, txt);
	}
	
	function undoUpdate() {
		var txt;
		
		if(ds_stack_empty(UNDO_STACK)) {
			txt = "-" + get_text("undo", "Undo");
		} else {
			var act = ds_stack_top(UNDO_STACK);
			if(array_length(act) > 1)
				txt = get_text("undo", "Undo") + " " + string(array_length(act)) + " " + get_text("actions", "Actions");
			else 
				txt = get_text("undo", "Undo") + " " + act[0].toString();
		}
		
		menus[1][1][0][0] = txt;
		
		if(ds_stack_empty(REDO_STACK)) {
			txt = "-" + get_text("redo", "Redo");
		} else {
			var act = ds_stack_top(REDO_STACK);
			if(array_length(act) > 1)
				txt = get_text("redo", "Redo") + " " + string(array_length(act)) + " " + get_text("actions", "Actions");
			else 
				txt = get_text("redo", "Redo") + " " + act[0].toString();
		}
		
		menus[1][1][1][0] = txt;
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		draw_sprite_ui_uniform(THEME.icon_24, 0, h / 2, h / 2, 1, c_white);
		var xx = h;
		
		menus[6] = STEAM_ENABLED? menu_help_steam : menu_help;
		
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
					var dia = dialogCall(o_dialog_menubox, x + xx, y + h);
					dia.setMenu(menus[i][1]);
				}
			}
			
			draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
			draw_text_over(xx + ww / 2, y + h / 2, menus[i][0]);
			
			xx += ww + 8;
		}
		
		#region notification
			var warning_amo = ds_list_size(WARNING);
			var error_amo = ds_list_size(ERRORS);
			
			var nx0 = xx + ui(24);
			var ny0 = y + h / 2;
			
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
		
		#region window
			var wh = ui(32);
			var cc = c_white;
			
			with(addon) {
				draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
				var ww = string_width(name) + ui(16);
				
				if(other.pHOVER && point_in_rectangle(other.mx, other.my, nx0, ny0 - wh / 2, nx0 + ww, ny0 + wh / 2)) {
					draw_sprite_stretched_ext(THEME.menu_button, 1, nx0, ny0 - wh / 2, ww, wh, cc, 1);
					if(mouse_press(mb_left, other.pFOCUS)) 
						instance_destroy();
				} else 
					draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, nx0, ny0 - wh / 2, ww, wh, cc, 1);
				draw_text(nx0 + ww / 2, ny0, name);
				
				nx0 += ww + ui(4);
			}
		#endregion
		
		#region version
			draw_set_text(f_p0, fa_right, fa_center, COLORS._main_text_sub);
			var txt = "v. " + string(VERSION_STRING);
			if(DEMO) txt += " DEMO";
			var ww = string_width(txt);
			if(pHOVER && point_in_rectangle(mx, my, w - ui(16) - ww, 0, w - ui(16), h)) {
				draw_sprite_stretched(THEME.menu_button, 0, w - ww - ui(22), ui(6), ww + ui(12), h - ui(12));
			
				if(mouse_press(mb_left, pFOCUS)) {
					dialogCall(o_dialog_release_note); 
				}
			}
			draw_text(w - ui(16), h / 2, txt);
		
			if(o_main.version_latest > VERSION) 
				displayNewVersion();
		#endregion
			
		undoUpdate();
	}
}