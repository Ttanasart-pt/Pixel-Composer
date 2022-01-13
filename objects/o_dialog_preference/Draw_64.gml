/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(FOCUS == self)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	
	draw_set_text(f_p0, fa_left, fa_center, c_ui_blue_ltgrey);
	draw_text(dialog_x + 24, dialog_y + 24, "Preferences");
#endregion

#region page
	var yy = dialog_y + 64;
	var hh = yy - 8;
	var hg = 36;
	
	for(var i = 0; i < array_length(page); i++) {
		draw_set_text(f_p0, fa_left, fa_center, c_white);
		if(i == page_current) {
			draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + 16, hh, 160, hg);
		} else if(point_in_rectangle(mouse_mx, mouse_my, dialog_x, hh, dialog_x + 160, hh + hg)) {
			draw_sprite_stretched_ext(s_ui_panel_bg, 0, dialog_x + 16, hh, 160, hg, c_white, 0.5);
			if(mouse_check_button(mb_left)) {
				page_current = i;
			}
		}
			
		draw_text(dialog_x + 28, hh + hg / 2, page[i]);
		hh += hg;
	}
#endregion

#region draw
	draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + 160, yy - 8, dialog_w - 160 - 16, dialog_h - 56 - 8);
	
	tb_search.auto_update   = true;
	tb_search.no_empty		= false;
	tb_search.font			= f_p1;
	tb_search.active		= FOCUS == self;
	tb_search.hover			= HOVER == self;
	tb_search.draw(dialog_x + dialog_w - 16 - 200, dialog_y + 16, 200, 32, search_text, [mouse_mx, mouse_my]);
	draw_sprite_ext(s_search_16, 0, dialog_x + dialog_w - 16 - 200 - 16, dialog_y + 16 + 12, 1, 1, 0, c_ui_blue_grey, 1);
	
	if(page_current == 0) {
		sp_pref.active = HOVER == self;
		sp_pref.draw(dialog_x + 160 + 8, yy);
	} else if(page_current == 1) {
		if(mouse_check_button_pressed(mb_left)) hk_editing = noone;
		
		sp_hotkey.active = HOVER == self;
		sp_hotkey.draw(dialog_x + 160 + 8, yy);
	}
#endregion