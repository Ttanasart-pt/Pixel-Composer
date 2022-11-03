/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region text
	draw_set_text(f_p0, fa_center, fa_top, c_white);
	
	draw_text(dialog_x + dialog_w / 2, dialog_y + ui(24), warning_text);
#endregion