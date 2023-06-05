/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), __txtx("grid_title", "Grid settings"));
#endregion

#region draw
	var yy = dialog_y + ui(64);
	var ww = ui(128);
	
	cb_enable.setActiveFocus(sFOCUS, sHOVER);
	cb_enable.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, __txtx("grid_snap", "Snap to grid"));
	cb_enable.draw(dialog_x + dialog_w - ui(24) - ww / 2, yy, PANEL_GRAPH.node_drag_snap, mouse_ui,, fa_center, fa_center);
	
	yy += ui(40);
	tb_size.setActiveFocus(sFOCUS, sHOVER);
	tb_size.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, __txtx("grid_size", "Grid size"));
	tb_size.draw(dialog_x + dialog_w - ui(24), yy, ww, TEXTBOX_HEIGHT, PANEL_GRAPH.graph_line_s, mouse_ui,, fa_right, fa_center);
	
	yy += ui(40);
	sl_opacity.setActiveFocus(sFOCUS, sHOVER);
	sl_opacity.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, __txtx("grid_opacity", "Grid opacity"));
	sl_opacity.draw(dialog_x + dialog_w - ui(24), yy, ww, TEXTBOX_HEIGHT, PANEL_GRAPH.grid_opacity, mouse_ui, ui(52), fa_right, fa_center);
	
	yy += ui(40);
	cl_color.setActiveFocus(sFOCUS, sHOVER);
	cl_color.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, __txtx("grid_color", "Grid color"));
	cl_color.draw(dialog_x + dialog_w - ui(24) - ww, yy - TEXTBOX_HEIGHT / 2, ww, TEXTBOX_HEIGHT, PANEL_GRAPH.grid_color, mouse_ui);
#endregion