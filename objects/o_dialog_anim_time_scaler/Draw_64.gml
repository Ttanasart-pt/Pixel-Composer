/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), __txtx("anim_scale_title", "Animation scaler"));
#endregion

#region scaler
	var yy = dialog_y + ui(44);
	
	tb_scale_frame.register();
	tb_scale_frame.setActiveFocus(sFOCUS, sHOVER);
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy + ui(17), __txtx("anim_scale_target_frame_length", "Target frame length"));
	var tb_x = dialog_x + ui(200);
	tb_scale_frame.draw(tb_x, yy, ui(96), TEXTBOX_HEIGHT, scale_to, mouse_ui);
	
	var sx1 = tb_x + ui(96);
	draw_set_text(f_p1, fa_right, fa_top, COLORS._main_text_sub);
	draw_text(sx1, yy + ui(38), __txtx("anim_scale_scale_factor", "Scaling factor: ") + string(scale_to / ANIMATOR.frames_total));
	
	var bx = sx1 + ui(16);
	var by = yy;
	
	b_apply.register();
	b_apply.setActiveFocus(sFOCUS, sHOVER);
	b_apply.draw(bx, by, ui(36), ui(36), mouse_ui, THEME.button_lime);
#endregion