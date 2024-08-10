/// @description init

draw_sprite_stretched(THEME.textbox, 3, dialog_x, dialog_y, dialog_w, dialog_h);

if(hk_editing == noone)
	WIDGET_CURRENT = tb_search;
tb_search.setFocusHover(true, true);
tb_search.draw(dialog_x, dialog_y, dialog_w, ui(32), search_string);
tb_search.sprite_index = 0;

sc_content.setFocusHover(sFOCUS, sHOVER);
sc_content.draw(dialog_x, dialog_y + ui(32));

draw_set_color(CDEF.main_dkgrey);
draw_line(dialog_x, dialog_y + ui(32), dialog_x + dialog_w - 1, dialog_y + ui(32));

draw_sprite_stretched(THEME.textbox, 1, dialog_x, dialog_y, dialog_w, dialog_h);