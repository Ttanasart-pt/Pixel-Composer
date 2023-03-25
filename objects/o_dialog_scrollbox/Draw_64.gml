/// @description init
#region draw
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	
	WIDGET_CURRENT = tb_search;
	tb_search.setActiveFocus(true, true);
	tb_search.draw(dialog_x + ui(8), dialog_y + ui(8), dialog_w - ui(16), ui(24), search_string);
	tb_search.sprite_index = 0;
	
	sc_content.setActiveFocus(sHOVER, sFOCUS);
	sc_content.draw(dialog_x, dialog_y + ui(16 + 24));
	
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion