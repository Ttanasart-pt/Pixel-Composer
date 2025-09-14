/// @description init
#region base UI
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region draw
	tb_name.font = font;
	tb_name.setFocusHover(sFOCUS, sHOVER);
	
	var _tbx = dialog_x + ui( 4);
	var _tby = dialog_y + ui( 4);
	var _tbw = dialog_w - ui( 8);
	var _tbh = dialog_h - ui( 8);
	
	if(label != "") {
		draw_set_text(font, fa_left, fa_center, COLORS._main_icon);
		var _tw = string_width(label);
		draw_text_add(_tbx, _tby + _tbh / 2, label);
		
		_tbx += _tw + ui(4);
		_tbw -= _tw + ui(4);
	}
	
	tb_name.draw(_tbx, _tby, _tbw, _tbh, text, mouse_ui);
#endregion