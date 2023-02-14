/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
#endregion

#region text
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), "Lua reference");
	
	draw_sprite_stretched(THEME.ui_panel_bg, 0, dialog_x + ui(24), dialog_y + ui(48), dialog_w - ui(48), dialog_h - ui(72));
	
	sp_note.active = sHOVER;
	sp_note.draw(dialog_x + ui(40), dialog_y + ui(56));
#endregion