/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
#endregion

#region text
	draw_set_text(f_p0, fa_center, fa_top, COLORS._main_text);
	
	draw_text(dialog_x + dialog_w / 2, dialog_y + ui(24), warning_text);
#endregion