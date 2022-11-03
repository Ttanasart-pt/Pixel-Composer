/// @description init
#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region draw
	draw_set_text(f_p0b, fa_left, fa_top, c_white);
	draw_text(dialog_x + ui(16), dialog_y + ui(16), "Assets");
	
	draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + ui(16), dialog_y + ui(48), folderW - ui(8), dialog_h - ui(64));
	draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + ui(16) + folderW, dialog_y + ui(16), dialog_w - ui(32) - folderW, dialog_h - ui(32));
	
	folderPane.active = sHOVER;
	folderPane.draw(dialog_x + ui(16), dialog_y + ui(48));
	
	contentPane.active = sHOVER;
	contentPane.draw(dialog_x + ui(20) + folderW, dialog_y + ui(16));
#endregion