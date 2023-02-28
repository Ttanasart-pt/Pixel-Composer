/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), "Visibility settings");
#endregion

#region draw
	var yy = dialog_y + ui(64);
	
	cb_grid.setActiveFocus(sFOCUS, sHOVER);
	cb_grid.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, "Grid");
	cb_grid.draw(dialog_x + dialog_w - ui(48), yy, PANEL_GRAPH.show_grid, mouse_ui,, fa_center, fa_center);
	
	yy += ui(40);
	cb_dim.setActiveFocus(sFOCUS, sHOVER);
	cb_dim.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, "Dimension");
	cb_dim.draw(dialog_x + dialog_w - ui(48), yy, PANEL_GRAPH.show_dimension, mouse_ui,, fa_center, fa_center);
	
	yy += ui(40);
	cb_com.setActiveFocus(sFOCUS, sHOVER);
	cb_com.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, "Compute time");
	cb_com.draw(dialog_x + dialog_w - ui(48), yy, PANEL_GRAPH.show_compute, mouse_ui,, fa_center, fa_center);
#endregion