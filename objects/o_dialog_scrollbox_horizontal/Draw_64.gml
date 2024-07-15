/// @description init
#region draw
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	
	WIDGET_CURRENT = tb_search;
	tb_search.setFocusHover(true, true);
	tb_search.draw(dialog_x + ui(8), dialog_y + ui(8), dialog_w - ui(16) - ui(24 + 4), ui(24), search_string);
	tb_search.sprite_index = 0;
	
	sc_content.setFocusHover(sFOCUS, sHOVER);
	sc_content.draw(dialog_x + text_pad, dialog_y + ui(40));
	
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
	
	if(buttonInstant(THEME.button_hide, dialog_x + dialog_w - ui(8) - ui(24), dialog_y + ui(8), ui(24), ui(24), mouse_ui, sFOCUS, sHOVER, "", THEME.scrollbox_direction, horizon) == 2) {
		horizon = !horizon;
		setSize();
	}
#endregion