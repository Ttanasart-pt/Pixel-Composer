/// @description init
DIALOG_WINDOW_START

#region draw
	draw_sprite_stretched(THEME.dialog_menu, 0, _dialog_x, _dialog_y, dialog_w, dialog_h);
	
	var diax = _dialog_x + padding;
	var diay = _dialog_y + padding;
	var diaw =  dialog_w - padding * 2;
	var diah =  dialog_h - padding * 2;
	
	tb_search.activate();
	tb_search.setFocusHover(true, true);
	tb_search.draw(diax + ui(8), diay + ui(8), diaw - ui(16), ui(24), search_string);
	tb_search.sprite_index = 0;
	
	sc_content.verify(diaw, diah - ui(40));
	sc_content.setFocusHover(sFOCUS, sHOVER);
	sc_content.draw(diax, diay + ui(40));
	
	draw_sprite_stretched(THEME.dialog_menu, 1, _dialog_x, _dialog_y, dialog_w, dialog_h);
#endregion

DIALOG_WINDOW_END