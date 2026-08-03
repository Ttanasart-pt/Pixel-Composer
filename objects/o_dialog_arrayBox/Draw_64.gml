/// @description init
#region draw
	DIALOG_WINDOW_START
	draw_sprite_stretched(THEME.textbox, 3, _dialog_x, _dialog_y, dialog_w, dialog_h);
	
	sc_content.setFocusHover(sFOCUS, sHOVER);
	sc_content.draw(_dialog_x, _dialog_y);
	
	draw_sprite_stretched(THEME.textbox, 1, _dialog_x, _dialog_y, dialog_w, dialog_h);
	DIALOG_WINDOW_END
#endregion