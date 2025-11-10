/// @description init
#region base UI
	draw_set_font(f_p1);
	var lbw = string_width(label) + ui(8);
	dialog_w = lbw + tb_width + padding * 2;

	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
	
	draw_sprite_stretched(THEME.ui_panel_bg, 1, dialog_x + ui(4), dialog_y + ui(4), dialog_w - ui(8), dialog_h - ui(8));
	
#endregion

#region draw TB
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_icon);
	draw_text(dialog_x + padding, dialog_y + dialog_h / 2, label);
	
	tb_name.setFocusHover(sFOCUS, sHOVER);
	tb_name.draw(dialog_x + lbw + ui(8), dialog_y + padding, tb_width, dialog_h - padding * 2, name, mouse_ui);
#endregion