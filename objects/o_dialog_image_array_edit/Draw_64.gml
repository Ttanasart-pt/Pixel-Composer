/// @description init
if !ready exit;
if !target exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(padding), dialog_y + ui(20), __txtx("array_edit_title", "Image array edit"));
#endregion

#region content
	var px = dialog_x + ui(padding);
	var py = dialog_y + ui(title_height);
	var pw = dialog_w - ui(padding + padding);
	var ph = dialog_h - ui(title_height + padding);
	
	draw_sprite_stretched(THEME.ui_panel_bg, 0, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
	sp_content.setFocusHover(sFOCUS, sHOVER);
	sp_content.draw(px, py);
#endregion

#region button
	var bw = ui(28);
	var bh = ui(28);
	var bx = dialog_x + dialog_w - ui(padding - 8) - bw;
	var by = dialog_y + ui(18);
	
	if(buttonInstant(THEME.button_hide, bx, by, bw, bh, mouse_ui, sFOCUS, sHOVER, __txt("Add") + "...", THEME.add,, COLORS._main_value_positive) == 2) {
		var path = get_open_filenames(".png", "");
		key_release();
		if(path != "") {
			var paths = paths_to_array(path);
			var arr = target.getInputData(0);
			
			for( var i = 0, n = array_length(paths); i < n; i++ ) 
				array_push(arr, paths[i]);
			
			target.inputs[| 0].setValue(arr);
		}
	}
	
	bx -= ui(36);
	
	if(buttonInstant(THEME.button_hide, bx, by, bw, bh, mouse_ui, sFOCUS, sHOVER, __txtx("array_edit_sort_name", "Sort by name"), THEME.text) == 2)
		sortByName();
#endregion