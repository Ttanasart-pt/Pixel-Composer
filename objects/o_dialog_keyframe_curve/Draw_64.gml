/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), __txtx("anim_interpolation", "Interpolation curve"));
#endregion

#region draw
	if(value_target != noone) {
		editWidget.setFocusHover(sFOCUS, sHOVER);
		editWidget.draw(dialog_x + ui(16), dialog_y + ui(48), dialog_w - ui(32), dialog_h - ui(64), 
			value_target.inter_curve, mouse_ui);
	}
#endregion