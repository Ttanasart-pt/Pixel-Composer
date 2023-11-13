/// @description init
if !ready exit;
draw_set_color(c_black);
draw_set_alpha(0.5);
draw_rectangle(0, 0, WIN_W, WIN_H, false);
draw_set_alpha(1);

#region base UI
	DIALOG_DRAW_BG
	if(sFOCUS)
		DIALOG_DRAW_FOCUS
#endregion

#region text
	var py = dialog_y + ui(16);
	draw_set_text(f_h5, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), py, __txtx("crashed_title", "Restore project"));
	py += line_get_height(, 4);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), py, __txtx("crashed_content", "Restore previous project before crash?"));
	
	var bw = ui(96), bh = BUTTON_HEIGHT;
	var bx1 = dialog_x + dialog_w - ui(16);
	var by1 = dialog_y + dialog_h - ui(16);
	var bx0 = bx1 - bw;
	var by0 = by1 - bh;
	
	draw_set_text(f_p1, fa_center, fa_center, COLORS._main_text);
	var b = buttonInstant(THEME.button, bx0, by0, bw, bh, mouse_ui, sFOCUS, sHOVER);
	draw_text(bx0 + bw / 2, by0 + bh / 2, __txt("Ignore"));
	if(b == 2) 
		instance_destroy();
	
	bx0 -= bw + ui(12);
	var b = buttonInstant(THEME.button, bx0, by0, bw, bh, mouse_ui, sFOCUS, sHOVER);
	draw_text(bx0 + bw / 2, by0 + bh / 2, __txt("Restore"));
	if(b == 2) {
		var path = string(DIRECTORY) + "prev_crash.pxc";
		LOAD_PATH(path, true, true);
		instance_destroy();
	}
	
	bx0 = dialog_x + ui(16);
	var b = buttonInstant(THEME.button, bx0, by0, bw, bh, mouse_ui, sFOCUS, sHOVER);
	draw_text(bx0 + bw / 2, by0 + bh / 2, __txtx("crashed_log", "Log file") + "...");
	if(b == 2) {
		var path = string(DIRECTORY) + "crash_log.txt";
		if(file_exists(path)) shellOpenExplorer(path);
	}
#endregion