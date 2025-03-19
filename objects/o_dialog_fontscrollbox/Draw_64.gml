/// @description init
#region pos
	var hght = line_get_height(f_p0, 8);
	var hh   = array_length(curr_data) * hght + ui(40);
	
	dialog_h = min(max_h, hh);
#endregion

#region draw
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	
	WIDGET_CURRENT = tb_search;
	tb_search.setFocusHover(true, true);
	tb_search.draw(dialog_x + ui(8), dialog_y + ui(8), dialog_w - ui(16), ui(24), search_string);
	tb_search.sprite_index = 0;
	
	sc_content.verify(dialog_w - ui(6), dialog_h - ui(40));
	sc_content.setFocusHover(sFOCUS, sHOVER);
	sc_content.draw(dialog_x, dialog_y + ui(40));
	
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion