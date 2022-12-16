/// @description init
#region draw
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
	sc_content.active = sHOVER;
	sc_content.draw(dialog_x, dialog_y);
#endregion