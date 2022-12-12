/// @description init
if !ready exit;
if !target exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), "Image array edit");
#endregion

#region content
	var x0 = dialog_x + ui(20);
	var x1 = x0 + sp_content.w;
	var y0 = dialog_y + ui(56);
	var y1 = y0 + sp_content.h;
	
	draw_sprite_stretched(THEME.ui_panel_bg, 1, x0 - ui(6), y0 - ui(6), x1 - x0 + ui(12), y1 - y0 + ui(12));
	sp_content.active = sFOCUS;
	sp_content.draw(x0, y0);
#endregion

#region button
	var bx = dialog_x + dialog_w - ui(108);
	var by = y0;
	
	if(buttonInstant(THEME.button, bx, by, ui(88), ui(40), mouse_ui, sFOCUS, sHOVER) == 2) {
		var path = get_open_filenames(".png", "");
		if(path != "") {
			var paths = paths_to_array(path);
			var arr = target.inputs[| 0].getValue();
			
			for( var i = 0; i < array_length(paths); i++ ) 
				array_push(arr, paths[i]);
				
			target.inputs[| 0].setValue(arr);
		}
	}
	
	draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
	draw_text(bx + ui(44), by + ui(20), "Add...");
#endregion