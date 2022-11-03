/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region text
	draw_set_text(f_p0, fa_left, fa_top, c_ui_blue_ltgrey);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), string(VERSION_STRING) + " Release note");
	
	draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + ui(24), dialog_y + ui(48), dialog_w - ui(48), dialog_h - ui(72));
	
	sp_note.active = sHOVER;
	sp_note.draw(dialog_x + ui(40), dialog_y + ui(56));
#endregion