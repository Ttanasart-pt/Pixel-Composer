/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
#endregion

#region text
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), "Notification");
	
	var ww = ui(32);
	var hh = ui(32);
	var bx = dialog_x + dialog_w - ui(24) - ww;
	var by = dialog_y + ui(16) + line_height() / 2 - hh / 2;
	
	var error = !!(filter & NOTI_TYPE.error);
	var b = buttonInstant(THEME.button_hide, bx, by, ww, hh, mouse_ui, sFOCUS, sHOVER,, THEME.noti_icon_error, error, c_white, 0.3 + error * 0.7);
	if(b == 2) filter = filter ^ NOTI_TYPE.error;
	if(b == 3) dialogCall(o_dialog_menubox, mouse_mx + ui(8), mouse_my + ui(8)).setMenu(rightClickMenu);
	bx -= ui(36);
	
	var warn = !!(filter & NOTI_TYPE.warning);
	var b = buttonInstant(THEME.button_hide, bx, by, ww, hh, mouse_ui, sFOCUS, sHOVER,, THEME.noti_icon_warning, warn, c_white, 0.3 + warn * 0.7);
	if(b == 2) filter = filter ^ NOTI_TYPE.warning;
	if(b == 3) dialogCall(o_dialog_menubox, mouse_mx + ui(8), mouse_my + ui(8)).setMenu(rightClickMenu);
	bx -= ui(36);
	
	var log = !!(filter & NOTI_TYPE.log);
	var b = buttonInstant(THEME.button_hide, bx, by, ww, hh, mouse_ui, sFOCUS, sHOVER,, THEME.noti_icon_log, log, c_white, 0.3 + log * 0.7);
	if(b == 2) filter = filter ^ NOTI_TYPE.log;
	if(b == 3) dialogCall(o_dialog_menubox, mouse_mx + ui(8), mouse_my + ui(8)).setMenu(rightClickMenu);
	
	draw_sprite_stretched(THEME.ui_panel_bg, 0, dialog_x + ui(24), dialog_y + ui(48), dialog_w - ui(48), dialog_h - ui(72));
	sp_noti.active = sHOVER;
	sp_noti.draw(dialog_x + ui(40), dialog_y + ui(56));
#endregion