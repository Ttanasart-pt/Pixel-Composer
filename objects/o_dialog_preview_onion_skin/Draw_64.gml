/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), __txt("Onion Skin"));
#endregion

#region draw
	var yy = dialog_y + ui(64);
	var ww = ui(208);
	
	cb_enable.setFocusHover(sFOCUS, sHOVER);
	cb_enable.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, __txt("Enabled"));
	cb_enable.draw(dialog_x + dialog_w - ui(24) - ww / 2, yy, PROJECT.onion_skin.enabled, mouse_ui,, fa_center, fa_center);
	
	yy += ui(40);
	cb_top.setFocusHover(sFOCUS, sHOVER);
	cb_top.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, __txtx("onion_skin_top", "Draw on top"));
	cb_top.draw(dialog_x + dialog_w - ui(24) - ww / 2, yy, PROJECT.onion_skin.on_top, mouse_ui,, fa_center, fa_center);
	
	yy += ui(40);
	tb_step.setFocusHover(sFOCUS, sHOVER);
	tb_step.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, __txt("Frame step"));
	tb_step.draw(dialog_x + dialog_w - ui(24), yy, ww, TEXTBOX_HEIGHT, PROJECT.onion_skin.step, mouse_ui,, fa_right, fa_center);
	
	yy += ui(40);
	cl_color_pre.setFocusHover(sFOCUS, sHOVER);
	cl_color_pre.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, __txt("Pre Color"));
	cl_color_pre.draw(dialog_x + dialog_w - ui(24) - ww, yy - TEXTBOX_HEIGHT / 2, ww, TEXTBOX_HEIGHT, PROJECT.onion_skin.color[0], mouse_ui);
	
	yy += ui(40);
	cl_color_post.setFocusHover(sFOCUS, sHOVER);
	cl_color_post.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, __txt("Post Color"));
	cl_color_post.draw(dialog_x + dialog_w - ui(24) - ww, yy - TEXTBOX_HEIGHT / 2, ww, TEXTBOX_HEIGHT, PROJECT.onion_skin.color[1], mouse_ui);
	
	yy += ui(40);
	sl_opacity.setFocusHover(sFOCUS, sHOVER);
	sl_opacity.register();
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(32), yy, __txt("Opacity"));
	sl_opacity.draw(dialog_x + dialog_w - ui(24), yy, ww, TEXTBOX_HEIGHT, PROJECT.onion_skin.alpha, mouse_ui, ui(52), fa_right, fa_center);
#endregion