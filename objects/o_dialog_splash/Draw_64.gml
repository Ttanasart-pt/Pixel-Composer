/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
#endregion

#region content
	draw_sprite_ui_uniform(THEME.icon_64, 0, dialog_x + ui(56), dialog_y + ui(56));
	draw_set_text(f_h5, fa_left, fa_center, COLORS._main_text_accent);
	draw_text(dialog_x + ui(56 + 48), dialog_y + ui(56), "Pixel Composer");
	
	var bx = dialog_x + ui(56 + 48) + string_width("Pixel Composer") + ui(16);
	var by = dialog_y + ui(56);
	var txt = "v. " + VERSION_STRING;
	draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_sub);
	var ww = string_width(txt) + ui(16);
	var hh = line_height(, 16);
	if(buttonInstant(THEME.button_hide, bx, by - hh / 2, ww, hh, mouse_ui, sFOCUS, sHOVER) == 2) {
		dialogCall(o_dialog_release_note, WIN_W / 2, WIN_H / 2);
	}
	draw_text(bx + ui(8), by, txt);
	
	var bx = dialog_x + dialog_w - ui(52);
	var by = dialog_y + ui(16);
	if(buttonInstant(THEME.button_hide, bx, by, ui(36), ui(36), mouse_ui, sFOCUS, sHOVER, "Preference", THEME.gear) == 2) {
		dialogCall(o_dialog_preference, WIN_W / 2, WIN_H / 2);
	}
	
	bx -= ui(40);
	if(buttonInstant(THEME.button_hide, bx, by, ui(36), ui(36), mouse_ui, sFOCUS, sHOVER, "Show on startup", THEME.icon_splash_show_on_start, PREF_MAP[? "show_splash"]) == 2) {
		PREF_MAP[? "show_splash"] = !PREF_MAP[? "show_splash"];
		PREF_SAVE();
	}
	
	var x0 = dialog_x + ui(16);
	var x1 = x0 + ui(288);
	var y0 = dialog_y + ui(128);
	var y1 = dialog_y + dialog_h - ui(16);
	
	draw_set_text(f_p0, fa_left, fa_bottom, COLORS._main_text_sub);
	draw_text(x0, y0 - ui(4), "Recent files");
	draw_sprite_stretched(THEME.ui_panel_bg, 0, x0, y0, x1 - x0, y1 - y0);
	sp_recent.active = sFOCUS;
	sp_recent.draw(x0 + ui(6), y0);
	
	x0 = x1 + ui(16);
	x1 = dialog_x + dialog_w - ui(16);
	
	draw_set_text(f_p0, fa_left, fa_bottom, COLORS._main_text_sub);
	draw_text(x0, y0 - ui(4), "Sample projects");
	draw_sprite_stretched(THEME.ui_panel_bg, 0, x0, y0, x1 - x0, y1 - y0);
	sp_sample.active = sFOCUS;
	sp_sample.draw(x0 + ui(6), y0);
	
	draw_set_text(f_p1, fa_right, fa_bottom, COLORS._main_text_sub);
	draw_text(x1 - ui(82), y0 - ui(4), "Art by ");
	draw_sprite_ui_uniform(s_kenney, 0, x1, y0 - ui(4), 2, c_white, 0.5);
#endregion