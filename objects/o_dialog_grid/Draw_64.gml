/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(FOCUS == self)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	
	draw_set_text(f_p0, fa_left, fa_center, c_ui_blue_ltgrey);
	draw_text(dialog_x + 24, dialog_y + 24, "Grid settings");
#endregion

#region draw
	var yy = dialog_y + 44;
	
	tb_width.active = FOCUS == self; 
	tb_width.hover  = HOVER == self;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + 32, yy + 17, "Grid width");
	tb_width.draw(dialog_x + dialog_w - 24 - 96, yy, 96, 34, PANEL_PREVIEW.grid_width, [mouse_mx, mouse_my]);
	
	yy += 44;
	tb_height.active = FOCUS == self; 
	tb_height.hover  = HOVER == self;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + 32, yy + 17, "Grid height");
	tb_height.draw(dialog_x + dialog_w - 24 - 96, yy, 96, 34, PANEL_PREVIEW.grid_height, [mouse_mx, mouse_my]);
#endregion