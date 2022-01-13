function Panel_Menu(_panel) : PanelContent(_panel) constructor {
	draggable  = false;
	
	notification = "";
	noti_icon    = 0;
	noti_timeout = 0;
	noti_extra   = [];
	noti_extra_current   = [];
	
	static menus = [
		["File", [
			[ "New", function() { 
				NEW();
			}, ["", "New file"] ],
			[ "Open...", function() { LOAD(); }, ["", "Open"]  ],
			[ "Save", function() { SAVE(); }, ["", "Save"]  ],
			[ "Save as...", function() { SAVE_AS(); }, ["", "Save as"]  ],
			-1,
			[ "Preferences...", function() { dialogCall(o_dialog_preference, WIN_W / 2, WIN_H / 2); } ],
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
				var dia = dialogCall(o_dialog_grid, WIN_W / 2, WIN_H / 2); 
				dia.anchor = ANCHOR.none;
			} ],
		]], 
		["Animation", [
			[ "Animation setting...", function() { 
				var dia = dialogCall(o_dialog_animation, WIN_W / 2, WIN_H / 2); 
				dia.anchor = ANCHOR.none;
			} ],
			-1,
			[ "Animation scaler...", function() { 
				dialogCall(o_dialog_anim_time_scaler, WIN_W / 2, WIN_H / 2); 
			} ],
		]],
		["Rendering", [
			[ "Render all nodes", function() { 
				for(var i = 0; i < ds_list_size(NODES); i++) 
					NODES[| i].rendered = false;
				UPDATE = true; 
			}, ["", "Render all"] ]
		]],
		["Panels", [
			[ "Workspace", [
				[ s_workspace_0, function() { clearPanel(); PREF_MAP[? "panel_layout"] = 0; setPanel(); PREF_SAVE(); } ],
				[ s_workspace_1, function() { clearPanel(); PREF_MAP[? "panel_layout"] = 1; setPanel(); PREF_SAVE(); } ]
			]],
			-1,
			[ "Collections", function() {
				clearPanel();
				PREF_MAP[? "panel_collection"] = !PREF_MAP[? "panel_collection"];
				setPanel();
				PREF_SAVE();
			} ]
		]],
	]
	
	function showNoti(str, icon = -1) {
		notification = str;
		noti_extra_current = noti_extra;
		noti_extra = [];
		noti_timeout = 60 + string_length(str) * 15;
		
		noti_icon = icon;
	}
	
	function addNotiExtra(str) {
		array_push(noti_extra, str);
	}
	
	function drawContent() {
		draw_clear_alpha(c_ui_blue_black, 0);
		draw_sprite_ext(icon_24, 0, 20, 20, 1, 1, 0, c_white, 1);
		var xx = 40;
		
		if(FOCUS == panel && point_in_rectangle(mx, my, 0, 0, 40, 32)) {
			if(mouse_check_button_pressed(mb_left)) {
				dialogCall(o_dialog_about, WIN_W / 2, WIN_H / 2);
			}
		}
		
		for(var i = 0; i < array_length(menus); i++) {
			draw_set_text(f_p1, fa_center, fa_center, c_white);
			var ww = string_width(menus[i][0]) + 16;
			var xc = xx + ww / 2;
			
			if(HOVER == panel) {
				if(point_in_rectangle(mx, my, xc - ww / 2, 0, xc + ww / 2, h)) {
					draw_sprite_stretched(s_menu_button, 0, xc - ww / 2, 6, ww, h - 12);
					
					if((FOCUS == panel && mouse_check_button_pressed(mb_left)) || instance_exists(o_dialog_menubox)) {
						var dia = dialogCall(o_dialog_menubox, x + xx, y + h);
						dia.setMenu(menus[i][1]);
					}
				}
			}
			
			draw_set_text(f_p1, fa_center, fa_center, c_white);
			draw_text(xx + ww / 2, y + h / 2, menus[i][0]);
			
			xx += ww + 8;
		}
		
		if(notification != "") {
			draw_set_text(f_p0, fa_left, fa_center, c_ui_orange);
			
			var n_str = notification;
			var ex    = array_length(noti_extra_current);
			if(ex) n_str += " with " + string(ex) + " warning" + ((ex > 1)? "s." : "."); 
				
			var nx0 = xx + 24;
			var nw  = string_width(n_str) + 32 + (noti_icon != -1) * 24;
			var ny0 = y + h / 2;
			draw_sprite_stretched_ext(s_ui_panel_bg, 1, nx0, ny0 - 16, nw, 32, c_white, 1);
			if(noti_icon != -1) 
				draw_sprite(noti_icon, 0, nx0 + 24, ny0);
			draw_text(nx0 + 16 + (noti_icon != -1) * 24, ny0, n_str);
			
			if(point_in_rectangle(mx, my, nx0, ny0 - 16, nx0 + nw, ny0 + 16)) {
				var tip = "";
				for( var i = 0; i < ex; i++ )  {
					tip += noti_extra_current[i] + "\n";
				}
				TOOLTIP = tip;
			} else if(noti_timeout-- < 0) {
				notification = "";
				noti_extra   = [];
			}
		}
		
		draw_set_text(f_p0, fa_right, fa_center, c_ui_blue_grey);
		var txt = "v. " + string(VERSION_STRING);
		var ww = string_width(txt);
		if(HOVER == panel && point_in_rectangle(mx, my, w - 16 - ww, 0, w - 16, h)) {
			draw_sprite_stretched(s_menu_button, 0, w - 16 - ww - 6, 6, ww + 12, h - 12);
			
			if(FOCUS == panel && mouse_check_button_pressed(mb_left)) {
				dialogCall(o_dialog_release_note, WIN_W / 2, WIN_H / 2); 
			}
		}
		draw_text(w - 16, h / 2, txt);
		
		if(o_main.version_latest > VERSION) {
			var xx = w - 88;
			draw_set_text(f_p0b, fa_right, fa_center, c_ui_lime);
			var txt = " Newer version available ";
			var ww = string_width(txt);
			
			if(HOVER == panel && point_in_rectangle(mx, my, xx - ww, 0, xx, h)) {
				draw_sprite_stretched(s_menu_button, 0, xx - ww - 6, 6, ww + 12, h - 12);
				
				if(FOCUS == panel && mouse_check_button_pressed(mb_left)) {
					url_open("https://makham.itch.io/pixel-composer");
				}
			}
			
			draw_text(xx, h / 2, txt);
		}
	}
}