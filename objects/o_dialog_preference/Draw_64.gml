/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(56), dialog_y + ui(20), __txt("Preferences"));
	
	var bx = dialog_x + ui(24);
	var by = dialog_y + ui(18);
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, destroy_on_click_out? __txt("Pin") : __txt("Unpin"), 
		THEME.pin, !destroy_on_click_out, destroy_on_click_out? COLORS._main_icon : COLORS._main_icon_light) == 2)
			destroy_on_click_out = !destroy_on_click_out;
#endregion

#region page
	sp_page.setFocusHover(sFOCUS, sHOVER);
	sp_page.draw(dialog_x + ui(padding), dialog_y + ui(title_height));
#endregion

#region draw
	section_current = "";
	var px = dialog_x + ui(padding + page_width);
	var py = dialog_y + ui(title_height);
	var pw = dialog_w - ui(padding + page_width + padding);
	var ph = dialog_h - ui(title_height + padding);
	
	draw_sprite_stretched(THEME.ui_panel_bg, 0, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
	
	tb_search.auto_update   = true;
	tb_search.no_empty		= false;
	tb_search.font			= f_p1;
	tb_search.active		= sFOCUS;
	tb_search.hover			= sHOVER;
	tb_search.draw(dialog_x + dialog_w - ui(padding - 8), dialog_y + ui(title_height) / 2, ui(200), ui(28), search_text, mouse_ui, fa_right, fa_center);
	draw_sprite_ui_uniform(THEME.search, 0, dialog_x + dialog_w - ui(padding + 208), dialog_y + ui(title_height) / 2, 1, COLORS._main_text_sub);
	
	if(page_current == 0) {
		current_list = pref_global;
		sp_pref.setFocusHover(sFOCUS, sHOVER);
		sp_pref.draw(px, py);
	}  else if(page_current == 1) {
		current_list = pref_appr;
		sp_pref.setFocusHover(sFOCUS, sHOVER);
		sp_pref.draw(px, py);
	} else if(page_current == 2) {
		var _w = ui(200);
		var _h = TEXTBOX_HEIGHT;
		
		var _x   = dialog_x + dialog_w - ui(8);
		var bx   = _x - ui(48);
		var _txt = __txtx("pref_reset_color", "Reset colors");
		var b = buttonInstant(THEME.button_hide, bx, py, ui(32), ui(32), mouse_ui, sFOCUS, sHOVER, _txt, THEME.refresh);
		if(b == 2) {
			var path = DIRECTORY + "themes/" + PREF_MAP[? "theme"] + "/override.json";
			if(file_exists(path)) file_delete(path);
			loadColor(PREF_MAP[? "theme"]);
		}
		
		var x1 = dialog_x + ui(padding + page_width);
		var x2 = _x - ui(32);
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
		draw_text(x1 + ui(8), py + _h / 2, __txt("Theme"));
		sb_theme.setFocusHover(sFOCUS, sHOVER);
		sb_theme.draw(x2 - ui(24) - _w, py, _w, _h, PREF_MAP[? "theme"]);
		
		sp_colors.setFocusHover(sFOCUS, sHOVER);
		sp_colors.draw(px, py + ui(40));
	} else if(page_current == 3) {
		if(mouse_press(mb_left, sFOCUS)) 
			hk_editing = noone;
		
		sp_hotkey.setFocusHover(sFOCUS, sHOVER);
		sp_hotkey.draw(px, py);
	}
#endregion