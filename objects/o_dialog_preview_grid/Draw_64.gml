/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	
	draw_set_text(f_p0, fa_left, fa_top, c_ui_blue_ltgrey);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), "Grid settings");
#endregion

#region draw
	var yy = dialog_y + ui(64);
	var ww = ui(128);
	
	cb_enable.active = sFOCUS; 
	cb_enable.hover  = sHOVER;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + ui(32), yy, "Enabled");
	cb_enable.draw(dialog_x + dialog_w - ww / 2, yy, PANEL_PREVIEW.grid_show, mouse_ui,, fa_center, fa_center);
	
	yy += ui(40);
	tb_width.active = sFOCUS; 
	tb_width.hover  = sHOVER;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + ui(32), yy, "Grid width");
	tb_width.draw(dialog_x + dialog_w - ui(24), yy, ww, TEXTBOX_HEIGHT, PANEL_PREVIEW.grid_width, mouse_ui,, fa_right, fa_center);
	
	yy += ui(40);
	tb_height.active = sFOCUS; 
	tb_height.hover  = sHOVER;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + ui(32), yy, "Grid height");
	tb_height.draw(dialog_x + dialog_w - ui(24), yy, ww, TEXTBOX_HEIGHT, PANEL_PREVIEW.grid_height, mouse_ui,, fa_right, fa_center);
	
	yy += ui(40);
	sl_opacity.active = sFOCUS; 
	sl_opacity.hover  = sHOVER;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + ui(32), yy, "Grid opacity");
	sl_opacity.draw(dialog_x + dialog_w - ui(24), yy, ww, TEXTBOX_HEIGHT, PANEL_PREVIEW.grid_opacity, mouse_ui, ui(52), fa_right, fa_center);
	
	yy += ui(40);
	cl_color.active = sFOCUS; 
	cl_color.hover  = sHOVER;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + ui(32), yy, "Grid Color");
	cl_color.draw(dialog_x + dialog_w - ui(24) - ww, yy - TEXTBOX_HEIGHT / 2, ww, TEXTBOX_HEIGHT, PANEL_PREVIEW.grid_color, mouse_ui);
#endregion