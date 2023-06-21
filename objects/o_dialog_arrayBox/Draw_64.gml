/// @description init
#region draw
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	
	sc_content.setFocusHover(sFOCUS, sHOVER);
	sc_content.draw(dialog_x, dialog_y);
	
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion