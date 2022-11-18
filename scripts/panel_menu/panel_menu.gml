function Panel_Menu(_panel) : PanelContent(_panel) constructor {
	draggable  = false;
	
	noti_flash = 0;
	
	static menus = [
		["Vanilla", [
			[ "Init Data", function() { 
				__init_collection(); 
				__initAssets(); 
			} ],
			[ "Enable file drop", function() { o_main.setFileDrop(); } ],
			[ "Enable window hook", function() { o_main.setWindowHook(); } ],
			[ "Toggle debug overlay", function() { 
				DEBUG = !DEBUG; 
				show_debug_overlay(DEBUG); 
			} ],
		]],
	]
	
	function drawContent() {
		draw_clear_alpha(c_ui_blue_black, 0);
		draw_sprite_ui_uniform(icon_24, 0, h / 2, h / 2, 1, c_white);
		var xx = h;
		
		if(FOCUS == panel && point_in_rectangle(mx, my, 0, 0, ui(40), ui(32))) {
			if(mouse_check_button_pressed(mb_left)) {
				dialogCall(o_dialog_about);
			}
		}
		
		for(var i = 0; i < array_length(menus); i++) {
			draw_set_text(f_p1, fa_center, fa_center, c_white);
			var ww = string_width(menus[i][0]) + ui(16);
			var xc = xx + ww / 2;
			
			if(HOVER == panel) {
				if(point_in_rectangle(mx, my, xc - ww / 2, 0, xc + ww / 2, h)) {
					draw_sprite_stretched(s_menu_button, 0, xc - ww / 2, ui(6), ww, h - ui(12));
					
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
		
		#region notification
			//var warning_amo = ds_list_size(WARNING);
			//var error_amo = ds_list_size(ERRORS);
			
			//var nx0 = xx + ui(24);
			//var ny0 = y + h / 2;
			
			//draw_set_text(f_p0, fa_left, fa_center, c_ui_blue_ltgrey);
			//var wr_w = ui(20) + ui(8) + string_width(string(warning_amo));
			//var er_w = ui(20) + ui(8) + string_width(string(error_amo));
			
			//var nw = ui(16) + wr_w + ui(16) + er_w;
			//var nh = ui(32);
			
			//noti_flash = lerp_linear(noti_flash, 0, 0.02);
			//var ev = animation_curve_eval(ac_flash, noti_flash);
			//var cc = merge_color(c_white, c_ui_orange, ev);
			
			//if(point_in_rectangle(mx, my, nx0, ny0 - nh / 2, nx0 + nw, ny0 + nh / 2)) {
			//	draw_sprite_stretched_ext(s_menu_button, 0, nx0, ny0 - nh / 2, nw, nh, cc, 1);
			//	if(mouse_check_button_pressed(mb_left)) {
			//		var dia = dialogCall(o_dialog_notifications, nx0, ny0 + nh / 2 + ui(4));
			//		dia.anchor = ANCHOR.left | ANCHOR.top;
			//	}
				
			//	TOOLTIP = string(warning_amo) + " warnings " + string(error_amo) + " errors";
			//} else
			//	draw_sprite_stretched_ext(s_ui_panel_bg, 1, nx0, ny0 - nh / 2, nw, nh, cc, 1);
			
			//gpu_set_blendmode(bm_add);
			//draw_sprite_stretched_ext(s_menu_button_mask, 0, nx0, ny0 - nh / 2, nw, nh, cc, ev / 2);
			//gpu_set_blendmode(bm_normal);
			
			//var wr_x = nx0 + ui(8);
			//draw_sprite_ui_uniform(s_noti_icon_warning, warning_amo? 1 : 0, wr_x + ui(10), ny0);
			//draw_text(wr_x + ui(28), ny0, warning_amo);
			
			//var er_x = nx0 + ui(8) + wr_w + ui(16);
			//draw_sprite_ui_uniform(s_noti_icon_error, error_amo? 1 : 0, er_x + ui(10), ny0);
			//draw_text(er_x + ui(28), ny0, error_amo);
		#endregion
		
		draw_set_text(f_p0, fa_right, fa_center, c_ui_blue_grey);
		var txt = "v. " + string(VERSION_STRING);
		var ww = string_width(txt);
		if(HOVER == panel && point_in_rectangle(mx, my, w - ui(16) - ww, 0, w - ui(16), h)) {
			draw_sprite_stretched(s_menu_button, 0, w - ww - ui(22), ui(6), ww + ui(12), h - ui(12));
			
			if(FOCUS == panel && mouse_check_button_pressed(mb_left)) {
				dialogCall(o_dialog_release_note); 
			}
		}
		draw_text(w - ui(16), h / 2, txt);
		
		if(o_main.version_latest > VERSION) {
			var xx = w - ui(88);
			draw_set_text(f_p0b, fa_right, fa_center, c_ui_lime);
			var txt = " Newer version available ";
			var ww = string_width(txt);
			
			if(HOVER == panel && point_in_rectangle(mx, my, xx - ww, 0, xx, h)) {
				draw_sprite_stretched(s_menu_button, 0, xx - ww - ui(6), ui(6), ww + ui(12), h - ui(12));
				
				if(FOCUS == panel && mouse_check_button_pressed(mb_left)) {
					url_open("https://makham.itch.io/pixel-composer");
				}
			}
			
			draw_text(xx, h / 2, txt);
		}
	}
}