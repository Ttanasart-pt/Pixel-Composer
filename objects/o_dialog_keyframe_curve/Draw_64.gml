/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	
	draw_set_text(f_p0, fa_left, fa_top, c_ui_blue_ltgrey);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), "Interpolation curve");
#endregion

#region draw
	if(value_target != noone) {
		editWidget.active = sFOCUS;
		editWidget.hover  = sHOVER;
		editWidget.draw(dialog_x + ui(16), dialog_y + ui(48), dialog_w - ui(32), dialog_h - ui(64), 
			value_target.inter_curve, mouse_ui);
	}
#endregion