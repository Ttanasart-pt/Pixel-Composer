/// @description init
#region base UI
	draw_sprite_stretched(s_textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region draw TB
	draw_set_text(f_p0, fa_left, fa_center, c_ui_blue_ltgrey);
	draw_text(dialog_x + 8, dialog_y + dialog_h / 2, "Name ");
	
	tb_name.active = FOCUS == self;
	tb_name.hover  = HOVER == self;
	
	tb_name.draw(dialog_x + 64, dialog_y + 8, dialog_w - 64 - 8, dialog_h - 16, 
		"New file", [mouse_mx, mouse_my]);
#endregion