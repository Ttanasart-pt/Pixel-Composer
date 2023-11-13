/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(sFOCUS)
		DIALOG_DRAW_FOCUS
#endregion

#region text
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), string(VERSION_STRING) + " Release note");
	
	draw_sprite_stretched(THEME.ui_panel_bg, 1, dialog_x + ui(24), dialog_y + ui(48), dialog_w - ui(48), dialog_h - ui(72));
	
	sp_note.setFocusHover(sFOCUS, sHOVER);
	sp_note.draw(dialog_x + ui(40), dialog_y + ui(56));
#endregion