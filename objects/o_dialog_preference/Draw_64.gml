/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), "Preferences");
	
	var titlebar_h = ui(16) + line_height(f_p0, 16);
#endregion

#region page
	var yy = dialog_y + titlebar_h;
	var yl = yy - ui(8);
	var hg = line_height(f_p0, 16);
	
	for(var i = 0; i < array_length(page); i++) {
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		if(i == page_current) {
			draw_sprite_stretched(THEME.ui_panel_bg, 0, dialog_x + ui(16), yl, ui(160), hg);
		} else if(sHOVER && point_in_rectangle(mouse_mx, mouse_my, dialog_x, yl, dialog_x + ui(160), yl + hg)) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, dialog_x + ui(16), yl, ui(160), hg, c_white, 0.5);
			if(mouse_click(mb_left, sFOCUS))
				page_current = i;
		}
			
		draw_text(dialog_x + ui(28), yl + hg / 2, page[i]);
		yl += hg;
	}
#endregion

#region draw
	draw_sprite_stretched(THEME.ui_panel_bg, 0, dialog_x + ui(160), yy - ui(8), dialog_w - ui(176), dialog_h - titlebar_h - ui(16));
	
	tb_search.auto_update   = true;
	tb_search.no_empty		= false;
	tb_search.font			= f_p1;
	tb_search.active		= sFOCUS;
	tb_search.hover			= sHOVER;
	tb_search.draw(dialog_x + dialog_w - ui(16), dialog_y + titlebar_h / 2, ui(200), ui(28), search_text, mouse_ui,, fa_right, fa_center);
	draw_sprite_ui_uniform(THEME.search, 0, dialog_x + dialog_w - ui(232), dialog_y + titlebar_h / 2, 1, COLORS._main_text_sub);
	
	if(page_current == 0) {
		current_list = pref_global;
		sp_pref.active = sHOVER;
		sp_pref.draw(dialog_x + ui(168), yy);
	} else if(page_current == 1) {
		current_list = pref_node;
		sp_pref.active = sHOVER;
		sp_pref.draw(dialog_x + ui(168), yy);
	} else if(page_current == 2) {
		current_list = pref_appr;
		sp_pref.active = sHOVER;
		sp_pref.draw(dialog_x + ui(168), yy);
	} else if(page_current == 3) {
		var _w = ui(200);
		var _h = TEXTBOX_HEIGHT;
		
		var _x = dialog_x + dialog_w - ui(8);
		var bx = _x - ui(48);
		var b = buttonInstant(THEME.button_hide, bx, yy, ui(32), ui(32), mouse_ui, sFOCUS, sHOVER, "Reset colors", THEME.refresh);
		if(b == 2) {
			var path = DIRECTORY + "themes/" + PREF_MAP[? "theme"] + "/override.json";
			if(file_exists(path)) file_delete(path);
			loadColor(PREF_MAP[? "theme"]);
		}
		
		var x1 = dialog_x + ui(168);
		var x2 = _x - ui(32);
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
		draw_text(x1 + ui(8), yy + _h / 2, "Theme");
		sb_theme.active = sFOCUS; 
		sb_theme.hover  = sHOVER;
		sb_theme.draw(x2 - ui(24) - _w, yy, _w, _h, PREF_MAP[? "theme"]);
		
		sp_colors.active = sHOVER;
		sp_colors.draw(dialog_x + ui(168), yy + ui(40));
	} else if(page_current == 4) {
		if(mouse_press(mb_left, sFOCUS)) 
			hk_editing = noone;
		
		sp_hotkey.active = sHOVER;
		sp_hotkey.draw(dialog_x + ui(168), yy);
	}
#endregion