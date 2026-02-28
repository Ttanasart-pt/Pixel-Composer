/// @description init
#region pos
	var hght = line_get_height(f_p0, 8);
	var hh   = array_length(curr_data) * hght + ui(40);
	if(search_string != "") hh += ui(24);
	
	dialog_h = min(max_h, hh);
#endregion

#region draw
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	
	var _tx = dialog_x + ui(8);
	var _ty = dialog_y + ui(8);
	var _tw = dialog_w - ui(16);
	var _th = ui(24);
	
	var _txt = __txt("Sort by Name");
	if(buttonInstant_Pad(THEME.button_hide, _tx + _tw - _th, _ty, _th, _th, mouse_ui, sHOVER, sFOCUS, _txt, THEME.text) == 2) {
		sort_invert = !sort_invert;
		sortSearch();
	}
	_tw -= _th + ui(4);
	
	tb_search.activate();
	tb_search.setFocusHover(true, true);
	tb_search.draw(_tx, _ty, _tw, _th, search_string);
	tb_search.sprite_index = 0;
	
	sc_content.verify(dialog_w - ui(6), dialog_h - ui(40));
	sc_content.setFocusHover(sFOCUS, sHOVER);
	sc_content.draw(dialog_x, dialog_y + ui(40));
	
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion