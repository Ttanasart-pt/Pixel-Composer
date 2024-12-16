/// @description init
if !ready exit;
if !target exit;

#region base UI
	DIALOG_DRAW_BG
	if(sFOCUS)
		DIALOG_DRAW_FOCUS
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(padding), dialog_y + ui(20), __txtx("array_edit_title", "Image array edit"));
#endregion

#region content
	var px = dialog_x + ui(padding);
	var py = dialog_y + ui(title_height);
	var pw = dialog_w - ui(padding + padding);
	var ph = dialog_h - ui(title_height + padding);
	
	draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
	sp_content.setFocusHover(sFOCUS, sHOVER);
	sp_content.draw(px, py);
#endregion

#region button
	var bw = ui(28);
	var bh = ui(28);
	var bx = dialog_x + dialog_w - ui(padding - 8) - bw;
	var by = dialog_y + ui(18);
	
	if(buttonInstant(THEME.button_hide, bx, by, bw, bh, mouse_ui, sHOVER, sFOCUS, __txt("Add") + "...", THEME.add,, COLORS._main_value_positive) == 2) {
		
		var path = get_open_filenames_compat("image|*.png;*.jpg", "");
		key_release();
		
		if(path != "") {
			var paths = string_splice(path, "\n");
			var arr   = target.getValue();
			array_append(arr, paths);
			
			target.setValue(arr);
			target.node.triggerRender();
		}
	}
	
	bx -= ui(36);
	
	if(buttonInstant(THEME.button_hide, bx, by, bw, bh, mouse_ui, sHOVER, sFOCUS, __txtx("array_edit_sort_name", "Sort by name"), THEME.text) == 2)
		sortByName();
#endregion