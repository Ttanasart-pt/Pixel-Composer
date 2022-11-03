/// @description init
#region base UI
	draw_sprite_stretched(s_textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region draw TB
	draw_set_text(f_p0, fa_left, fa_top, c_ui_blue_ltgrey);
	draw_text(dialog_x + ui(8), dialog_y + dialog_h / 2, "Name ");
	
	tb_name.active = sFOCUS;
	tb_name.hover  = sHOVER;
	
	tb_name.draw(dialog_x + ui(64), dialog_y + ui(8), dialog_w - ui(72), dialog_h - ui(16), 
		"New file", mouse_ui);
#endregion