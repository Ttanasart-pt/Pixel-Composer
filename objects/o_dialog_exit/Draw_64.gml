/// @description init
if !ready exit;

#region dim BG
	var lowest = true;
	with(o_dialog_exit) {
		if(id == other.id) continue;
		if(depth > other.depth) lowest = false;
	}

	if(lowest) {
		draw_set_color(c_black);
		draw_set_alpha(0.5);
		draw_rectangle(0, 0, WIN_W, WIN_H, false);
		draw_set_alpha(1);
	}
#endregion

#region base UI
	DIALOG_DRAW_BG
	if(sFOCUS)
		DIALOG_DRAW_FOCUS
#endregion

#region text
	var py  = dialog_y + ui(16);
	var txt = __txt($"Project modified");
	draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), py, txt);
	py += line_get_height(, 4);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	var txt = __txta("Save project '{1}' before exit?", filename_name(project.path));
	draw_text(dialog_x + ui(24), py, txt);
	
	var bw = ui(96), bh = BUTTON_HEIGHT;
	var bx1 = dialog_x + dialog_w - ui(16);
	var by1 = dialog_y + dialog_h - ui(16);
	var bx0 = bx1 - bw;
	var by0 = by1 - bh;
	
	draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
	var b = buttonInstant(THEME.button, bx0, by0, bw, bh, mouse_ui, sFOCUS, sHOVER);
	draw_text(bx0 + bw / 2, by0 + bh / 2, __txt("Cancel"));
	if(b == 2) 
		instance_destroy();
	
	bx0 -= bw + ui(12);
	var b = buttonInstant(THEME.button, bx0, by0, bw, bh, mouse_ui, sFOCUS, sHOVER);
	draw_text(bx0 + bw / 2, by0 + bh / 2, __txtx("dont_save", "Don't save"));
	if(b == 2) {
		if(instance_number(o_dialog_exit) == 1) 
			close_program();
		instance_destroy();
	}
	
	bx0 -= bw + ui(12);
	var b = buttonInstant(THEME.button, bx0, by0, bw, bh, mouse_ui, sFOCUS, sHOVER);
	draw_text(bx0 + bw / 2, by0 + bh / 2, __txt("Save"));
	if(b == 2 && SAVE(project)) {
		if(instance_number(o_dialog_exit) == 1) 
			close_program();
		instance_destroy();
	}
#endregion