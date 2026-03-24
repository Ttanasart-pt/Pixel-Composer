/// @description init
#region base UI
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region draw
	tb_name.setFont(font);
	tb_name.setFocusHover(sFOCUS, sHOVER);
	
	var _tbx = dialog_x + ui(4);
	var _tby = dialog_y + ui(4);
	var _tbh = tbh;
	var _tbw = dialog_w - ui(8) - (_tbh + ui(4)) * 2;
	
	if(label != "") {
		draw_set_text(font, fa_left, fa_center, COLORS._main_icon);
		var _tw = string_width(label);
		draw_text_add(_tbx, _tby + _tbh / 2, label);
		
		_tbx += _tw + ui(4);
		_tbw -= _tw + ui(4);
	}
	
	tb_name.draw(_tbx, _tby, _tbw, _tbh, text, mouse_ui);
	
	var m = mouse_ui;
	var hov = sHOVER;
	var foc = sFOCUS;
	
	var bb = THEME.button_hide;
	
	var bs = tbh;
	var bx = _tbx + _tbw + ui(4) + bs/2;
	var by = _tby + _tbh / 2;
	var bp = THEME.splash_thumbnail;
	var bi = !update_thumbnail;
	if(buttonInstant_Icon(bx, by, bs/2, m, hov, foc, __txt("Update Thumbnail"), bp, bi) == 2)
		update_thumbnail = !update_thumbnail;
	
	bx += bs + ui(4);
	var bp = THEME.accept_16;
	var bc = COLORS._main_value_positive;
	if(buttonInstant(bb, bx-bs/2, by-bs/2, bs, bs, m, hov, foc, __txt("Update"), bp, 0, bc) == 2)
		update();
	
	if(KEYBOARD_ENTER) update();
#endregion