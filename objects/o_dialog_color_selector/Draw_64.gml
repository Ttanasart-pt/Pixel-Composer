/// @description init
if !ready exit;

#region dropper
	if(selector.dropper_active) {
		selector.drawDropper(self);
		exit;
	}
#endregion

#region base UI
	var presets_x  = dialog_x;
	var presets_w  = ui(240);
	
	var content_x = dialog_x + presets_w + ui(16);
	var content_w = dialog_w - presets_w - ui(16);
	
	draw_sprite_stretched(THEME.dialog_bg, 0, presets_x, dialog_y, presets_w, dialog_h);
	if(sFOCUS) draw_sprite_stretched_ext(THEME.dialog_active, 0, presets_x, dialog_y, presets_w, dialog_h, COLORS._main_accent, 1);
	
	draw_sprite_stretched(THEME.dialog_bg, 0, content_x, dialog_y, content_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, content_x, dialog_y, content_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(presets_x + ui(24), dialog_y + ui(16), "Palettes");
	draw_text(content_x + ui(24), dialog_y + ui(16), name);
#endregion

#region palette
	draw_sprite_stretched(THEME.ui_panel_bg, 0, presets_x + ui(16), dialog_y + ui(44), ui(240 - 32), dialog_h - ui(60));
	
	sp_presets.active = sFOCUS;
	sp_presets.draw(presets_x + ui(24), dialog_y + ui(44));
	
	var bx = presets_x + presets_w - ui(44);
	var by = dialog_y + ui(12);
	
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, "Refresh", THEME.refresh) == 2)
		presetCollect();
	bx -= ui(32);
	
	if(buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, "Open palette folder", THEME.folder) == 2) {
		var _realpath = environment_get_variable("LOCALAPPDATA") + "\\Pixels_Composer\\Palettes";
		var _windir   = environment_get_variable("WINDIR") + "\\explorer.exe";
		execute_shell(_windir, _realpath);
	}
	bx -= ui(32);
#endregion

#region selector
	var col_x = content_x + ui(20);
	var col_y = dialog_y + ui(52);
	
	selector.draw(col_x, col_y, sFOCUS, sHOVER);
#endregion

#region controls
	var bx = content_x + content_w - ui(36);
	var by = dialog_y + dialog_h - ui(36);
	
	b_apply.register();
	b_apply.hover  = sHOVER;
	b_apply.active = sFOCUS;
	b_apply.draw(bx - ui(18), by - ui(18), ui(36), ui(36), mouse_ui, THEME.button_lime);
#endregion