/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
#endregion

#region about
	var cx = dialog_x + dialog_w / 2;
	var ly = dialog_y + ui(96);
	
	draw_sprite_ui_uniform(THEME.icon_64, 0, cx, dialog_y + ui(56));
	draw_sprite_ui_uniform(s_title, 0, cx - ui(256 * .4), ly, .4 * THEME_SCALE);
	ly += ui(32);
	
	draw_set_text(f_p3, fa_center, fa_top);
	draw_set_color(COLORS._main_text_sub);
	draw_text(cx, ly - ui(4), code_is_compiled()? "Native build" : "VM build");
	ly += string_height("l");
	
	draw_set_text(f_p0, fa_center, fa_top, COLORS._main_text_sub);
	draw_text(cx, ly, "2025, MakhamDev");
	
	var _padd   = ui(20);
	var thank_x = dialog_x + _padd;
	var thank_y = dialog_y + ui(188);
	var thank_w = dialog_w - _padd * 2;
	var thank_h = dialog_h - ui(188) - _padd;
	
	draw_sprite_stretched(THEME.ui_panel_bg, 1, thank_x - ui(8), thank_y - ui(8), thank_w + ui(16), thank_h + ui(16));
	sc_thank.setFocusHover(sFOCUS, sHOVER);
	sc_thank.verify(thank_w, thank_h);
	sc_thank.draw(thank_x, thank_y);
#endregion