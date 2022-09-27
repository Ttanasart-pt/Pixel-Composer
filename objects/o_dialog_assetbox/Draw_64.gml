/// @description init
#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(FOCUS == self)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region draw
	draw_set_text(f_p0b, fa_left, fa_top, c_white);
	draw_text(dialog_x + 16, dialog_y + 16, "Assets");
	
	draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + 16, dialog_y + 40, folderW - 8, dialog_h - 16 - 40);
	draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + 16 + folderW, dialog_y + 16, dialog_w - 16 - folderW - 16, dialog_h - 32);
	
	folderPane.active = HOVER == self;
	folderPane.draw(dialog_x + 16, dialog_y + 48);
	
	contentPane.active = HOVER == self;
	contentPane.draw(dialog_x + 20 + folderW, dialog_y + 16);
#endregion