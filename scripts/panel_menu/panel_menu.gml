function Panel_Menu() : PanelContent() constructor {
	draggable  = false;
	
	noti_flash = 0;
	
	menus = [
		["File", [
			[ "New", function() { 
				NEW();
			}, ["", "New file"] ],
			[ "Open...", function() { LOAD(); }, ["", "Open"]  ],
			[ "Open...", function() { LOAD(); }, ["", "Open"]  ],
			[ "Save", function() { SAVE(); }, ["", "Save"]  ],
			[ "Save as...", function() { SAVE_AS(); }, ["", "Save as"]  ],
			[ "Recent files", function(_x, _y, _depth) { 
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
			[ "Preferences...", function() { dialogCall(o_dialog_preference); } ],
			[ "Splash screen", function() { dialogCall(o_dialog_splash); } ],
		]],
		["Edit", [
			[ "Undo", function() { UNDO(); }, ["", "Undo"]  ],
			[ "Redo", function() { REDO(); }, ["", "Redo"]  ],
		]],
		["Preview", [
			[ "Center preview", function() { PANEL_PREVIEW.do_fullView = true; }, ["Preview", "Focus content"] ], 
			[ "Save current preview as...", function() { PANEL_PREVIEW.saveCurrentFrame(); }, ["Preview", "Save current frame"] ], 
			[ "Preview background", [
				[ s_menu_transparent,	function() { PANEL_PREVIEW.canvas_bg = -1; } ],
				[ s_menu_white,			function() { PANEL_PREVIEW.canvas_bg = c_white; } ],
				[ s_menu_black,			function() { PANEL_PREVIEW.canvas_bg = c_black; } ],
			]], 
			-1,
			[ "Show Grid", function() { PANEL_PREVIEW.grid_show = !PANEL_PREVIEW.grid_show; }, ["Preview", "Toggle grid"] ],
			[ "Grid setting...", function() { 
				var dia = dialogCall(o_dialog_preview_grid); 
				dia.anchor = ANCHOR.none;
			} ],
		]], 
		["Animation", [
			[ "Animation setting...", function() { 
				var dia = dialogCall(o_dialog_animation); 
				dia.anchor = ANCHOR.none;
			} ],
			-1,
			[ "Animation scaler...", function() { 
				dialogCall(o_dialog_anim_time_scaler); 
			} ],
		]],
		["Rendering", [
			[ "Render all nodes", function() { 
				for(var i = 0; i < ds_list_size(NODES); i++) 
					NODES[| i].setRenderStatus(false);
				UPDATE |= RENDER_TYPE.full; 
			}, ["", "Render all"] ]
		]],
		["Panels", [
			[ "Workspace", [
				[ THEME.workspace_horizontal, function() { clearPanel(); PREF_MAP[? "panel_layout"] = 0; setPanel(); PREF_SAVE(); } ],
				[ THEME.workspace_vertical, function() { clearPanel(); PREF_MAP[? "panel_layout"] = 1; setPanel(); PREF_SAVE(); } ]
			]],
			-1,
			[ "Collections", function() {
				clearPanel();
				PREF_MAP[? "panel_collection"] = !PREF_MAP[? "panel_collection"];
				setPanel();
				PREF_SAVE();
			} ],
		]],
	]
	
	function displayNewVersion() {
		var xx = w - ui(88);
		draw_set_text(f_p0b, fa_right, fa_center, COLORS._main_value_positive);
		var txt = " Newer version available ";
		var ww = string_width(txt);
			
		if(pHOVER && point_in_rectangle(mx, my, xx - ww, 0, xx, h)) {
			draw_sprite_stretched(THEME.menu_button, 0, xx - ww - ui(6), ui(6), ww + ui(12), h - ui(12));
				
			if(pFOCUS && mouse_check_button_pressed(mb_left)) {
				url_open("https://makham.itch.io/pixel-composer");
			}
		}
			
		draw_text(xx, h / 2, txt);
	}
	
	function undoUpdate() {
		var txt;
		
		if(ds_stack_empty(UNDO_STACK)) {
			txt = "-Undo";
		} else {
			var act = ds_stack_top(UNDO_STACK);
			if(array_length(act) > 1)
				txt = "Undo " + string(array_length(act)) + " actions";
			else 
				txt = "Undo " + act[0].toString();
		}
		
		menus[1][1][0][0] = txt;
		
		if(ds_stack_empty(REDO_STACK)) {
			txt = "-Redo";
		} else {
			var act = ds_stack_top(REDO_STACK);
			if(array_length(act) > 1)
				txt = "Redo " + string(array_length(act)) + " actions";
			else 
				txt = "Redo " + act[0].toString();
		}
		
		menus[1][1][1][0] = txt;
	}
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		draw_sprite_ui_uniform(THEME.icon_24, 0, h / 2, h / 2, 1, c_white);
		var xx = h;
		
		if(pFOCUS && point_in_rectangle(mx, my, 0, 0, ui(40), ui(32))) {
			if(mouse_check_button_pressed(mb_left)) {
				dialogCall(o_dialog_about);
			}
		}
		
		for(var i = 0; i < array_length(menus); i++) {
			draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
			var ww = string_width(menus[i][0]) + ui(16);
			var xc = xx + ww / 2;
			
			if(pHOVER) {
				if(point_in_rectangle(mx, my, xc - ww / 2, 0, xc + ww / 2, h)) {
					draw_sprite_stretched(THEME.menu_button, 0, xc - ww / 2, ui(6), ww, h - ui(12));
					
					if((pFOCUS && mouse_check_button_pressed(mb_left)) || instance_exists(o_dialog_menubox)) {
						var dia = dialogCall(o_dialog_menubox, x + xx, y + h);
						dia.setMenu(menus[i][1]);
					}
				}
			}
			
			draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
			draw_text(xx + ww / 2, y + h / 2, menus[i][0]);
			
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
			
			var nw = ui(16) + wr_w + ui(16) + er_w;
			var nh = ui(32);
			
			noti_flash = lerp_linear(noti_flash, 0, 0.02);
			var ev = animation_curve_eval(ac_flash, noti_flash);
			var cc = merge_color(c_white, COLORS._main_accent, ev);
			
			if(point_in_rectangle(mx, my, nx0, ny0 - nh / 2, nx0 + nw, ny0 + nh / 2)) {
				draw_sprite_stretched_ext(THEME.menu_button, 0, nx0, ny0 - nh / 2, nw, nh, cc, 1);
				if(mouse_check_button_pressed(mb_left)) {
					var dia = dialogCall(o_dialog_notifications, nx0, ny0 + nh / 2 + ui(4));
					dia.anchor = ANCHOR.left | ANCHOR.top;
				}
				
				TOOLTIP = string(warning_amo) + " warnings " + string(error_amo) + " errors";
			} else
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, nx0, ny0 - nh / 2, nw, nh, cc, 1);
			
			gpu_set_blendmode(bm_add);
			draw_sprite_stretched_ext(THEME.menu_button_mask, 0, nx0, ny0 - nh / 2, nw, nh, cc, ev / 2);
			gpu_set_blendmode(bm_normal);
			
			var wr_x = nx0 + ui(8);
			draw_sprite_ui_uniform(THEME.noti_icon_warning, warning_amo? 1 : 0, wr_x + ui(10), ny0);
			draw_text(wr_x + ui(28), ny0, warning_amo);
			
			var er_x = nx0 + ui(8) + wr_w + ui(16);
			draw_sprite_ui_uniform(THEME.noti_icon_error, error_amo? 1 : 0, er_x + ui(10), ny0);
			draw_text(er_x + ui(28), ny0, error_amo);
		#endregion
		
		draw_set_text(f_p0, fa_right, fa_center, COLORS._main_text_sub);
		var txt = "v. " + string(VERSION_STRING);
		var ww = string_width(txt);
		if(pHOVER && point_in_rectangle(mx, my, w - ui(16) - ww, 0, w - ui(16), h)) {
			draw_sprite_stretched(THEME.menu_button, 0, w - ww - ui(22), ui(6), ww + ui(12), h - ui(12));
			
			if(pFOCUS && mouse_check_button_pressed(mb_left)) {
				dialogCall(o_dialog_release_note); 
			}
		}
		draw_text(w - ui(16), h / 2, txt);
		
		if(o_main.version_latest > VERSION) 
			displayNewVersion();
			
		undoUpdate();
	}
}