/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
	
	draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
	draw_text(dialog_x + ui(20), dialog_y + ui(8), __txtx("add_images_title_direcory", "Import directory"));
#endregion

#region directory option
	var dw = dialog_w - ui(120);
	var dh = ui(32);
	
	var dx = dialog_x + dialog_w - dw - ui(16);
	var dy = dialog_y + title_h;
	
	cb_recursive.setFocusHover(sFOCUS, sHOVER);
	cb_recursive.draw(dx, dy, dw, dh, dir_recursive, mouse_ui);
		
	draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(20), dy + dh/2, __txt("Recursive"));
	
	dy += dh + ui(8);
	tb_filter.setFocusHover(sFOCUS, sHOVER);
	tb_filter.draw(dx, dy, dw, dh, dir_filter, mouse_ui);
		
	draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
	draw_text(dialog_x + ui(20), dy + dh/2, __txt("Filter"));
	
	var bw = ui(100);
	var bx = dialog_x + dialog_w - ui(16) - bw;
	dy += dh + ui(8);
	
	if(buttonInstant(THEME.button_def, bx, dy, bw, dh, mouse_ui, sHOVER, sFOCUS) == 2) {
		if(target) {
			var paths = paths_to_array_ext(dir_paths, dir_filter);
			target.updatePaths(paths);
			target.doUpdate();
		}
		instance_destroy();
	}
	
	draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
	draw_text(bx + bw / 2, dy + dh/2, __txt("Import"));
#endregion