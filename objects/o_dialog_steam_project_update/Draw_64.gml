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
	
	var _bs = tbh;
	var _bx = _tbx + _tbw + ui(4) + _bs/2;
	var _by = _tby + _tbh / 2;
	if(buttonInstant_Icon(_bx, _by, _bs/2, mouse_ui, sHOVER, sFOCUS, "Update Thumbnail", THEME.splash_thumbnail, !update_thumbnail) == 2) {
		update_thumbnail = !update_thumbnail;
	}
	
	_bx += _bs + ui(4);
	if(buttonInstant(THEME.button_hide, _bx - _bs/2, _by - _bs/2, _bs, _bs, mouse_ui, sHOVER, sFOCUS, "Update", THEME.accept_16, 0, COLORS._main_value_positive) == 2) {
		update();
	}
	
	if(KEYBOARD_ENTER) update();
#endregion