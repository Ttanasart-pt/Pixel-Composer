/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	
	draw_set_text(f_p0, fa_left, fa_top, c_ui_blue_ltgrey);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), "Preferences");
	
	var titlebar_h = ui(16) + line_height(f_p0, 16);
#endregion

#region page
	var yy = dialog_y + titlebar_h;
	var yl = yy - ui(8);
	var hg = line_height(f_p0, 8);
	
	for(var i = 0; i < array_length(page); i++) {
		draw_set_text(f_p0, fa_left, fa_center, c_white);
		if(i == page_current) {
			draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + ui(16), yl, ui(160), hg);
		} else if(point_in_rectangle(mouse_mx, mouse_my, dialog_x, yl, dialog_x + ui(160), yl + hg)) {
			draw_sprite_stretched_ext(s_ui_panel_bg, 0, dialog_x + ui(16), yl, ui(160), hg, c_white, 0.5);
			if(mouse_check_button(mb_left))
				page_current = i;
		}
			
		draw_text(dialog_x + ui(28), yl + hg / 2, page[i]);
		yl += hg;
	}
#endregion

#region draw
	draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + ui(160), yy - ui(8), dialog_w - ui(176), dialog_h - titlebar_h - ui(16));
	
	tb_search.auto_update   = true;
	tb_search.no_empty		= false;
	tb_search.font			= f_p1;
	tb_search.active		= sFOCUS;
	tb_search.hover			= sHOVER;
	tb_search.draw(dialog_x + dialog_w - ui(16), dialog_y + titlebar_h / 2, ui(200), TEXTBOX_HEIGHT, search_text, mouse_ui,, fa_right, fa_center);
	draw_sprite_ui_uniform(s_search_16, 0, dialog_x + dialog_w - ui(232), dialog_y + titlebar_h / 2, 1, c_ui_blue_grey);
	
	if(page_current == 0) {
		current_list = pref_global;
		sp_pref.active = sHOVER;
		sp_pref.draw(dialog_x + ui(168), yy);
	} else if(page_current == 1) {
		current_list = pref_node;
		sp_pref.active = sHOVER;
		sp_pref.draw(dialog_x + ui(168), yy);
	} else if(page_current == 2) {
		if(mouse_check_button_pressed(mb_left)) hk_editing = noone;
		
		sp_hotkey.active = sHOVER;
		sp_hotkey.draw(dialog_x + ui(168), yy);
	}
#endregion