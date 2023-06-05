/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), __txt("Animation"));
#endregion

#region draw
	var yy = dialog_y + ui(44);
	
	tb_length.setActiveFocus(sFOCUS, sHOVER);
	tb_length.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy + ui(17), __txtx("anim_length", "Animation length"));
	tb_length.draw(dialog_x + dialog_w - ui(120), yy, ui(96), TEXTBOX_HEIGHT, ANIMATOR.frames_total, mouse_ui);
	
	yy += ui(44);
	tb_framerate.setActiveFocus(sFOCUS, sHOVER);
	tb_framerate.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy + ui(17), __txtx("anim_frame_rate", "Preview frame rate"));
	tb_framerate.draw(dialog_x + dialog_w - ui(120), yy, ui(96), TEXTBOX_HEIGHT, ANIMATOR.framerate, mouse_ui);
	
	yy += ui(44);
	eb_playback.setActiveFocus(sFOCUS, sHOVER);
	eb_playback.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy + ui(17), __txtx("anim_on_end", "On end"));
	eb_playback.draw(dialog_x + dialog_w - ui(152), yy, ui(128), TEXTBOX_HEIGHT, ANIMATOR.playback, mouse_ui);
#endregion