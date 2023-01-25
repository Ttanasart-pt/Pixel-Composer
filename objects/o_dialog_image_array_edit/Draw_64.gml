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
	var bw = ui(32);
	var bh = ui(32);
	
	var bx = x1 - ui(10) - ui(16);
	var by = dialog_y + ui(12);
	
	if(buttonInstant(THEME.button_hide, bx, by, bw, bh, mouse_ui, sFOCUS, sHOVER, "Add...", THEME.add,, COLORS._main_value_positive) == 2) {
		var path = get_open_filenames(".png", "");
		if(path != "") {
			var paths = paths_to_array(path);
			var arr = target.inputs[| 0].getValue();
			
			for( var i = 0; i < array_length(paths); i++ ) 
				array_push(arr, paths[i]);
			
			target.inputs[| 0].setValue(arr);
		}
	}
	
	bx -= ui(32 + 4);
	
	if(buttonInstant(THEME.button_hide, bx, by, bw, bh, mouse_ui, sFOCUS, sHOVER, "Sort by name", THEME.text) == 2)
		sortByName();
#endregion