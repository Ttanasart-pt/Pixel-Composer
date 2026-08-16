/// @description init
DIALOG_WINDOW_START

#region base UI
	draw_set_font(f_p2);
	var lbw = string_width(label) + ui(8);
	dialog_w = lbw + tb_width + padding * 2;

	draw_sprite_stretched(THEME.textbox, 3, _dialog_x, _dialog_y, dialog_w, dialog_h);
	draw_sprite_stretched(THEME.textbox, 1, _dialog_x, _dialog_y, dialog_w, dialog_h);
	
	draw_sprite_stretched(THEME.ui_panel_bg, 1, _dialog_x + ui(4), _dialog_y + ui(4), dialog_w - ui(8), dialog_h - ui(8));
#endregion

#region draw TB
	var tx = _dialog_x + lbw + ui(8);
	var ty = _dialog_y + padding;
	var tw = tb_width;
	var th = dialog_h - padding * 2;
	
	var bs = th;
	var bx = _dialog_x + dialog_w - padding - bs;
	var by = _dialog_y + padding;
	var bb = THEME.button_hide_fill;
	
	var bc = COLORS._main_value_negative;
	if(buttonInstant(bb, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, "", THEME.cross_16, 0, bc) == 2)
		instance_destroy();
	bx -= bs + ui(4); tw -= bs + ui(4);
	
	var bc = COLORS._main_value_positive;
	if(buttonInstant(bb, bx, by, bs, bs, mouse_ui, sHOVER, sFOCUS, "", THEME.accept_16, 0, bc) == 2) {
		onModify(filename_combine(path, filename_name_validate(tb_name._input_text))); 
		WIDGET_CURRENT = undefined;
		instance_destroy();
	}
	bx -= bs + ui(4); tw -= bs + ui(4);
	
	tw -= ui(4);
	draw_set_text(f_p2, fa_left, fa_center, COLORS._main_icon);
	draw_text(_dialog_x + padding, _dialog_y + dialog_h / 2, label);
	
	tb_name.setFocusHover(sFOCUS, sHOVER);
	tb_name.draw(tx, ty, tw, th, name, mouse_ui);
#endregion

DIALOG_WINDOW_END