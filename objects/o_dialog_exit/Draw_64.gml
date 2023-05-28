/// @description init
if !ready exit;

draw_set_color(c_black);
draw_set_alpha(0.5);
draw_rectangle(0, 0, WIN_W, WIN_H, false);
draw_set_alpha(1);

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
#endregion

#region text
	var py = dialog_y + ui(16);
	draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(24), py, "Project modified");
	py += line_get_height(, 4);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), py, "Save progress before exit?");
	
	var bw = ui(96), bh = TEXTBOX_HEIGHT;
	var bx1 = dialog_x + dialog_w - ui(16);
	var by1 = dialog_y + dialog_h - ui(16);
	var bx0 = bx1 - bw;
	var by0 = by1 - bh;
	
	draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
	var b = buttonInstant(THEME.button, bx0, by0, bw, bh, mouse_ui, sFOCUS, sHOVER);
	draw_text(bx0 + bw / 2, by0 + bh / 2, "Cancel");
	if(b == 2) 
		instance_destroy();
	
	bx0 -= bw + ui(12);
	var b = buttonInstant(THEME.button, bx0, by0, bw, bh, mouse_ui, sFOCUS, sHOVER);
	draw_text(bx0 + bw / 2, by0 + bh / 2, "Don't save");
	if(b == 2) {
		PREF_SAVE();
		game_end();
	}
	
	bx0 -= bw + ui(12);
	var b = buttonInstant(THEME.button, bx0, by0, bw, bh, mouse_ui, sFOCUS, sHOVER);
	draw_text(bx0 + bw / 2, by0 + bh / 2, "Save");
	if(b == 2 && SAVE()) {
		PREF_SAVE();
		game_end();
	}
#endregion