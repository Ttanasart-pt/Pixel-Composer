/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(FOCUS == self)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	
	draw_set_text(f_p0, fa_left, fa_center, c_ui_blue_ltgrey);
	draw_text(dialog_x + 24, dialog_y + 24, "Animation");
#endregion

#region draw
	var yy = dialog_y + 44;
	
	tb_length.active = FOCUS == self; 
	tb_length.hover  = HOVER == self;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + 32, yy + 17, "Animation length");
	tb_length.draw(dialog_x + dialog_w - 24 - 96, yy, 96, 34, ANIMATOR.frames_total, [mouse_mx, mouse_my]);
	
	yy += 44;
	tb_framerate.active = FOCUS == self; 
	tb_framerate.hover  = HOVER == self;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + 32, yy + 17, "Preview frame rate");
	tb_framerate.draw(dialog_x + dialog_w - 24 - 96, yy, 96, 34, ANIMATOR.framerate, [mouse_mx, mouse_my]);
	
	yy += 44;
	eb_playback.active = FOCUS == self; 
	eb_playback.hover  = HOVER == self;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + 32, yy + 17, "On end");
	eb_playback.draw(dialog_x + dialog_w - 24 - 128, yy, 128, 34, ANIMATOR.playback, [mouse_mx, mouse_my]);
#endregion