/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(FOCUS == self)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	
	draw_set_text(f_p0, fa_left, fa_center, c_ui_blue_ltgrey);
	draw_text(dialog_x + 24, dialog_y + 24, "Import directory");
#endregion

#region directory option
	var dir_y = dialog_y + 44;
		
	cb_recursive.active = FOCUS == self;
	cb_recursive.hover  = HOVER == self;
	cb_recursive.draw(dialog_x + dialog_w - 48, dir_y, dir_recursive, [mouse_mx, mouse_my]);
		
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + 20, dir_y + 14, "Recursive");
		
	dir_y += 40;
	tb_filter.active = FOCUS == self;
	tb_filter.hover  = HOVER == self;
	tb_filter.draw(dialog_x + 100, dir_y, dialog_w - 100 - 20, 36, dir_filter, [mouse_mx, mouse_my]);
		
	draw_set_text(f_p1, fa_left, fa_center, c_white);
	draw_text(dialog_x + 20, dir_y + 18, "Filter");
	
	var bx = dialog_x + dialog_w - 20 - 100;
	dir_y += 48;
	
	if(buttonInstant(s_button, bx, dir_y, 100, 40, [mouse_mx, mouse_my], FOCUS == self, HOVER == self) == 2) {
		if(target) {
			var paths = paths_to_array(dir_paths, dir_recursive, dir_filter);
			target.updatePaths(paths);
			target.doUpdate();
		}
		instance_destroy();
	}
	
	draw_set_text(f_p0b, fa_center, fa_center, c_ui_orange);
	draw_text(bx + 50, dir_y + 20, "Import");
#endregion