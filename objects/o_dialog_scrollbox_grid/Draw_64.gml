/// @description init
DIALOG_WINDOW_START
#region draw
	draw_sprite_stretched(THEME.textbox, 3, _dialog_x, _dialog_y, dialog_w, dialog_h);
	
	tb_search.activate();
	tb_search.setFocusHover(true, true);
	tb_search.draw(_dialog_x + ui(8), _dialog_y + ui(8), dialog_w - ui(16), ui(24), search_string);
	tb_search.sprite_index = 0;
	
	sc_content.setFocusHover(sFOCUS, sHOVER);
	sc_content.draw(_dialog_x, _dialog_y + ui(40));
	
	draw_sprite_stretched(THEME.textbox, 1, _dialog_x, _dialog_y, dialog_w, dialog_h);
#endregion
DIALOG_WINDOW_END