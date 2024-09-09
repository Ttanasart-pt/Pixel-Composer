/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(sFOCUS)
		DIALOG_DRAW_FOCUS
#endregion

#region about
	var cx = dialog_x + dialog_w / 2;
	var ly = dialog_y + ui(96);
	
	draw_sprite_ui_uniform(THEME.icon_64, 0, cx, dialog_y + ui(56));
	draw_set_text(_f_ico_h5, fa_center, fa_top, COLORS._main_text_accent);
	draw_text(cx, ly, "Pixel Composer");
	ly += string_height("l");
	
	draw_set_font(f_p3);
	draw_set_color(COLORS._main_text_sub);
	draw_text(cx, ly - ui(4), code_is_compiled()? "Native build" : "VM build");
	ly += string_height("l");
	
	draw_set_text(f_p0, fa_center, fa_top, COLORS._main_text_sub);
	draw_text(cx, ly, "2024, MakhamDev");
	
	var thank_y = dialog_y + ui(188);
	draw_sprite_stretched(THEME.ui_panel_bg, 1, dialog_x + ui(24), thank_y - ui(8), dialog_w - ui(48), thank_h + ui(16));
	sc_thank.setFocusHover(sFOCUS, sHOVER);
	sc_thank.draw(dialog_x + ui(32), thank_y);
#endregion