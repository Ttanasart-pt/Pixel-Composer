/// @description init
if !ready exit;

#region base UI
	var aa = 0.75;
	if(point_in_rectangle(mouse_mx, mouse_my, dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h)) {
		aa = 1;
	} else if(--life < 0)
		instance_destroy();
	
	draw_sprite_stretched_ext(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, aa);
	draw_sprite_stretched_ext(THEME.textbox, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	draw_sprite_stretched_ext(THEME.textbox_header, 0, dialog_x, dialog_y, ui(32), dialog_h, COLORS._main_accent, 1);
#endregion

#region text
	draw_sprite_ui(THEME.noti_icon_warning, 1, dialog_x + ui(16), dialog_y + dialog_h / 2);
	
	draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text);
	draw_text_line(dialog_x + ui(32) + padding, dialog_y + padding, warning_text, -1, dialog_w - padding * 2 - ui(32));
#endregion