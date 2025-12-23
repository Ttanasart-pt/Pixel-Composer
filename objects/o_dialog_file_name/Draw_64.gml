/// @description init
#region base UI
	draw_set_font(f_p2);
	var lbw = string_width(label) + ui(8);
	dialog_w = lbw + tb_width + padding * 2;

	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
	
	draw_sprite_stretched(THEME.ui_panel_bg, 1, dialog_x + ui(4), dialog_y + ui(4), dialog_w - ui(8), dialog_h - ui(8));
	
#endregion

#region draw TB
	var tx = dialog_x + lbw + ui(8);
	var ty = dialog_y + padding;
	var tw = tb_width;
	var th = dialog_h - padding * 2;
	
	var bs = th;
	var bx = dialog_x + dialog_w - padding - bs;
	var by = dialog_y + padding;
	var bb = THEME.button_hide_fill;
	
	var bc = COLORS._main_value_negative;
	if(buttonInstant(bb, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, __txt("Close"), THEME.cross_16, 0, bc) == 2)
		instance_destroy();
	bx -= bs + ui(4); tw -= bs + ui(4);
	
	var bc = COLORS._main_value_positive;
	if(buttonInstant(bb, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, __txt("Accept"), THEME.accept_16, 0, bc) == 2) {
		onModify(path + filename_name_validate(name)); 
		instance_destroy();
	}
	bx -= bs + ui(4); tw -= bs + ui(4);
	
	tw -= ui(4);
	draw_set_text(f_p2, fa_left, fa_center, COLORS._main_icon);
	draw_text(dialog_x + padding, dialog_y + dialog_h / 2, label);
	
	tb_name.setFocusHover(sFOCUS, sHOVER);
	tb_name.draw(tx, ty, tw, th, name, mouse_ui);
#endregion