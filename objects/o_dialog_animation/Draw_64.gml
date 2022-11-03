/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	
	draw_set_text(f_p0, fa_left, fa_top, c_ui_blue_ltgrey);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), "Animation");
#endregion

#region draw
	var yy = dialog_y + ui(44);
	
	tb_length.active = sFOCUS; 
	tb_length.hover  = sHOVER;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + ui(32), yy + ui(17), "Animation length");
	tb_length.draw(dialog_x + dialog_w - ui(120), yy, ui(96), TEXTBOX_HEIGHT, ANIMATOR.frames_total, mouse_ui);
	
	yy += ui(44);
	tb_framerate.active = sFOCUS; 
	tb_framerate.hover  = sHOVER;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + ui(32), yy + ui(17), "Preview frame rate");
	tb_framerate.draw(dialog_x + dialog_w - ui(120), yy, ui(96), TEXTBOX_HEIGHT, ANIMATOR.framerate, mouse_ui);
	
	yy += ui(44);
	eb_playback.active = sFOCUS; 
	eb_playback.hover  = sHOVER;
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + ui(32), yy + ui(17), "On end");
	eb_playback.draw(dialog_x + dialog_w - ui(152), yy, ui(128), TEXTBOX_HEIGHT, ANIMATOR.playback, mouse_ui);
#endregion