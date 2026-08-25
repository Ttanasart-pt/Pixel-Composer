/// @description init

DIALOG_WINDOW_START

if(!is_winwin(window))
	draw_sprite_stretched(THEME.dialog_shadow, 0, _dialog_x-DIALOG_PAD, _dialog_y-DIALOG_PAD, dialog_w+DIALOG_PAD*2, dialog_h+DIALOG_PAD*2);
draw_sprite_stretched(THEME.dialog, 0, _dialog_x, _dialog_y, dialog_w, dialog_h);

if(hk_editing == noone) tb_search.activate();
tb_search.setFocusHover(sHOVER, sFOCUS);
tb_search.draw(_dialog_x + ui(32), _dialog_y, dialog_w - ui(32), ui(32), search_string);
tb_search.sprite_index = 0;

draw_sprite_ui(THEME.search, 0, _dialog_x + ui(20), _dialog_y + ui(16), 1, 1, 0, COLORS._main_icon, 1);

sc_content.setFocusHover(sFOCUS, sHOVER);
sc_content.draw(_dialog_x, _dialog_y + ui(32));

draw_set_color(CDEF.main_dkgrey);
draw_line(_dialog_x, _dialog_y + ui(32), _dialog_x + dialog_w - 1, _dialog_y + ui(32));

// draw_sprite_stretched_ext(THEME.textbox, 1, _dialog_x, _dialog_y, dialog_w, dialog_h, c_white);
draw_sprite_stretched_ext(THEME.dialog, 1, _dialog_x, _dialog_y, dialog_w, dialog_h, COLORS._main_icon, .2);

DIALOG_WINDOW_END