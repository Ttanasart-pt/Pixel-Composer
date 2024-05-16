/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(sFOCUS)
		DIALOG_DRAW_FOCUS
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), __txtx("add_images_title_direcory", "Import directory"));
#endregion

#region directory option
	var dir_y = dialog_y + ui(44);
	
	cb_recursive.setFocusHover(sFOCUS, sHOVER);
	cb_recursive.draw(dialog_x + dialog_w - ui(48), dir_y, dir_recursive, mouse_ui);
		
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(20), dir_y + ui(14), __txt("Recursive"));
	
	dir_y += ui(40);
	tb_filter.setFocusHover(sFOCUS, sHOVER);
	tb_filter.draw(dialog_x + ui(100), dir_y, dialog_w - ui(120), ui(36), dir_filter, mouse_ui);
		
	draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(20), dir_y + ui(18), __txt("Filter"));
	
	var bx = dialog_x + dialog_w - ui(120);
	dir_y += ui(48);
	
	if(buttonInstant(THEME.button_def, bx, dir_y, ui(100), ui(40), mouse_ui, sFOCUS, sHOVER) == 2) {
		if(target) {
			var paths = paths_to_array_ext(dir_paths, dir_filter);
			target.updatePaths(paths);
			target.doUpdate();
		}
		instance_destroy();
	}
	
	draw_set_text(f_p0b, fa_center, fa_center, COLORS._main_text_accent);
	draw_text(bx + ui(50), dir_y + ui(20), __txt("Import"));
#endregion