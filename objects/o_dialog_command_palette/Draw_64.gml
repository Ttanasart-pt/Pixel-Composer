/// @description init

DIALOG_WINDOW_START

if(!is_winwin(window))
	draw_sprite_stretched_ext(THEME.dialog_shadow, 0, _dialog_x-dpd, _dialog_y-dpd, dialog_w+dpd*2, dialog_h+dpd*2, c_white, display_a);
draw_sprite_stretched_ext(THEME.dialog, 0, _dialog_x, _dialog_y, dialog_w, dialog_h, c_white, display_a);

#region search
	var tx = _dialog_x + ui(32);
	var ty = _dialog_y;
	var tw = dialog_w - ui(32);
	var th = ui(32);

	if(hk_editing == noone) tb_search.activate();
	tb_search.setFocusHover(sHOVER, sFOCUS);
	tb_search.draw(tx, ty, tw, th, search_string);
	tb_search.sprite_index = 0;
	
	if(searching) {
		var ix = tx + tw - th / 2;
		var iy = ty + th / 2;
		
		draw_sprite_ui_uniform(THEME.loading, 0, ix, iy, .35, COLORS._main_icon, 1, current_time / 3);
	}
	
	draw_sprite_ui(THEME.search, 0, _dialog_x + ui(20), _dialog_y + ui(16), 1, 1, 0, COLORS._main_icon, 1);
#endregion

#region content
	sc_content.draw_alpha = display_a;
	sc_content.setFocusHover(sFOCUS, sHOVER);
	sc_content.verify(dialog_w - ui(2+4), dialog_h - ui(32) - 1);
	sc_content.draw(_dialog_x + ui(2), _dialog_y + ui(32));
	
	draw_set_color(CDEF.main_dkgrey);
	draw_line(_dialog_x, _dialog_y + ui(32), _dialog_x + dialog_w - 1, _dialog_y + ui(32));
	
	draw_sprite_stretched_ext(THEME.dialog, 1, _dialog_x, _dialog_y, dialog_w, dialog_h, COLORS._main_icon, .2 * display_a);
#endregion

DIALOG_WINDOW_END