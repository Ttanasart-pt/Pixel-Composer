/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(FOCUS == self)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	
	draw_set_text(f_p0, fa_left, fa_center, c_ui_blue_ltgrey);
	draw_text(dialog_x + 24, dialog_y + 24, "Interpolation curve");
	
	
#endregion

#region draw
	if(value_target != noone) {
		editWidget.active = FOCUS == self;
		editWidget.hover  = HOVER == self;
		editWidget.draw(dialog_x + 16, dialog_y + 48, dialog_w - 32, dialog_h - 48 - 16, 
			value_target.inter_curve, value_target.curve_type, [mouse_mx, mouse_my]);
	}
#endregion