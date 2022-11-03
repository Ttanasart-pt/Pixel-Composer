/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region text
	draw_set_text(f_p0, fa_left, fa_top, c_ui_blue_ltgrey);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), "Notification");
	
	var ww = ui(32);
	var hh = ui(32);
	var bx = dialog_x + dialog_w - ui(24) - ww;
	var by = dialog_y + ui(16) + line_height() / 2 - hh / 2;
	
	var error = !!(filter & NOTI_TYPE.error);
	if(buttonInstant(s_button_hide, bx, by, ww, hh, mouse_ui, sFOCUS, sHOVER,, s_noti_icon_error, error, c_white, 0.3 + error * 0.7) == 2)
		filter = filter ^ NOTI_TYPE.error;
	bx -= ui(36);
	
	var warn = !!(filter & NOTI_TYPE.warning);
	if(buttonInstant(s_button_hide, bx, by, ww, hh, mouse_ui, sFOCUS, sHOVER,, s_noti_icon_warning, warn, c_white, 0.3 + warn * 0.7) == 2)
		filter = filter ^ NOTI_TYPE.warning;
	bx -= ui(36);
	
	var log = !!(filter & NOTI_TYPE.log);
	if(buttonInstant(s_button_hide, bx, by, ww, hh, mouse_ui, sFOCUS, sHOVER,, s_noti_icon_log, log, c_white, 0.3 + log * 0.7) == 2)
		filter = filter ^ NOTI_TYPE.log;
	
	draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + ui(24), dialog_y + ui(48), dialog_w - ui(48), dialog_h - ui(72));
	sp_noti.active = sHOVER;
	sp_noti.draw(dialog_x + ui(40), dialog_y + ui(56));
#endregion