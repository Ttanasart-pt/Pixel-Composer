/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), __txtx("dialog_connection_title", "Connection settings"));
#endregion

#region draw
	var yy = dialog_y + ui(64);
	var ww = ui(128);
	
	bs_type.setActiveFocus(sFOCUS, sHOVER);
	bs_type.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, __txt("Type"));
	bs_type.draw(dialog_x + dialog_w - ui(24) - ww, yy - TEXTBOX_HEIGHT / 2, ww, TEXTBOX_HEIGHT, PREF_MAP[? "curve_connection_line"], mouse_ui);
	
	yy += ui(40);
	tb_width.setActiveFocus(sFOCUS, sHOVER);
	tb_width.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, __txtx("dialog_connection_thickness", "Line thickness"));
	tb_width.draw(dialog_x + dialog_w - ui(24), yy, ww, TEXTBOX_HEIGHT, PREF_MAP[? "connection_line_width"], mouse_ui,, fa_right, fa_center);
	
	yy += ui(40);
	tb_corner.setActiveFocus(sFOCUS, sHOVER);
	tb_corner.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, __txtx("dialog_connection_radius", "Corner radius"));
	tb_corner.draw(dialog_x + dialog_w - ui(24), yy, ww, TEXTBOX_HEIGHT, PREF_MAP[? "connection_line_corner"], mouse_ui,, fa_right, fa_center);
#endregion