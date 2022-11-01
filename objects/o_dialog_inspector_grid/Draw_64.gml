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
	var ww = 128;
	
	cb_enable.active = FOCUS == self; 
	cb_enable.hover  = HOVER == self;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + 32, yy + 17, "Snap to grid");
	cb_enable.draw(dialog_x + dialog_w - 24 - ww / 2 - 14, yy, PANEL_GRAPH.node_drag_snap, [mouse_mx, mouse_my]);
	
	yy += 40;
	tb_size.active = FOCUS == self; 
	tb_size.hover  = HOVER == self;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + 32, yy + 17, "Grid size");
	tb_size.draw(dialog_x + dialog_w - 24 - ww, yy, ww, 34, PANEL_GRAPH.graph_line_s, [mouse_mx, mouse_my]);
	
	yy += 40;
	sl_opacity.active = FOCUS == self; 
	sl_opacity.hover  = HOVER == self;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + 32, yy + 17, "Grid opacity");
	sl_opacity.draw(dialog_x + dialog_w - 24 - ww, yy, ww, 34, PANEL_GRAPH.grid_opacity, [mouse_mx, mouse_my], 52);
#endregion