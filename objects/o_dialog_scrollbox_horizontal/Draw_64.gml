/// @description init
#region draw
	draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);
	
	var _hori = horizon && search_string == "";
	var _tpad = _hori? text_pad : ui(8);
	
	var tbx = dialog_x + ui(8);
	var tby = dialog_y + ui(8);
	var tbw = dialog_w - ui(16);
	if(search_string == "") tbw -= ui(24 + 4);
	
	WIDGET_CURRENT = tb_search;
	tb_search.setFocusHover(true, true);
	tb_search.draw(tbx, tby, tbw, ui(24), search_string);
	tb_search.sprite_index = 0;
	
	sc_content.setFocusHover(sFOCUS, sHOVER);
	sc_content.draw(dialog_x + _tpad, dialog_y + ui(40));
	
	draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);
	
	if(search_string == "")
	if(buttonInstant(THEME.button_hide_fill, dialog_x + dialog_w - ui(8) - ui(24), dialog_y + ui(8), ui(24), ui(24), mouse_ui, sHOVER, sFOCUS, "", THEME.scrollbox_direction, horizon) == 2) {
		horizon = !horizon;
		setSize();
	}
#endregion