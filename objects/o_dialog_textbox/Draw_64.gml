/// @description init
#region base UI
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region draw
	tb_name.font = font;
	tb_name.setFocusHover(sFOCUS, sHOVER);
	
	var _tbx = dialog_x + ui( 8);
	var _tby = dialog_y + ui( 8);
	var _tbw = dialog_w - ui(16);
	var _tbh = dialog_h - ui(16);
	
	tb_name.draw(_tbx, _tby, _tbw, _tbh, text, mouse_ui);
#endregion