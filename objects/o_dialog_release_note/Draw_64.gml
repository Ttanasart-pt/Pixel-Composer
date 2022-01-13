/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(FOCUS == self)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region text
	draw_set_text(f_p0, fa_left, fa_center, c_ui_blue_ltgrey);
	draw_text(dialog_x + 24, dialog_y + 24, string(VERSION_STRING) + " Release note");
	
	draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + 24, dialog_y + 48, dialog_w - 48, dialog_h - 48 - 24);
	
	sp_note.active = HOVER == self;
	sp_note.draw(dialog_x + 40, dialog_y + 56);
#endregion