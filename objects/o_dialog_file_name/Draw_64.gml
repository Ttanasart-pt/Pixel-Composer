/// @description init
#region base UI
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region draw TB
	draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text_title);
	draw_text(dialog_x + ui(8), dialog_y + dialog_h / 2, "Name");
	
	tb_name.setActiveFocus(sFOCUS, sHOVER);
	tb_name.draw(dialog_x + ui(64), dialog_y + ui(8), dialog_w - ui(72), dialog_h - ui(16), 
		name, mouse_ui);
#endregion