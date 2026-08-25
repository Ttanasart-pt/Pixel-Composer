/// @description init
DIALOG_WINDOW_START
#region draw
	draw_sprite_stretched(THEME.dialog_menu, 0, _dialog_x, _dialog_y, dialog_w, dialog_h);
	
	var diax = _dialog_x + padding;
	var diay = _dialog_y + padding;
	var diaw =  dialog_w - padding * 2;
	var diah =  dialog_h - padding * 2;
	
	var _hori = horizon && search_string == "";
	var _tpad = _hori? text_pad : ui(8);
	
	var tbx = diax + ui(8);
	var tby = diay + ui(8);
	var tbw = diaw - ui(16);
	var tbh = ui(24);
	if(search_string == "") tbw -= ui(24 + 4);
	
	tb_search.activate();
	tb_search.setFocusHover(true, true);
	tb_search.draw(tbx, tby, tbw, tbh, search_string);
	tb_search.sprite_index = 0;
	
	sc_content.verify(diaw - _tpad * 2, diah - (_tpad * 2 + tbh));
	sc_content.setFocusHover(sFOCUS, sHOVER);
	sc_content.draw(diax + _tpad, diay + _tpad * 2 + tbh);
	
	draw_sprite_stretched(THEME.dialog_menu, 1, _dialog_x, diay, diaw, diah);
	
	if(search_string == "")
	if(buttonInstant(THEME.button_hide_fill, _dialog_x + dialog_w - ui(8) - ui(24), _dialog_y + ui(8), ui(24), ui(24), mouse_ui, sHOVER, sFOCUS, "", THEME.scrollbox_direction, horizon) == 2) {
		horizon = !horizon;
		setSize();
	}
#endregion
DIALOG_WINDOW_END