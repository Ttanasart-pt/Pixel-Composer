/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), dialog_y + ui(20), __txtx("dialog_group_order_title", "IO order"));
#endregion

#region preset
	var px = dialog_x + ui(padding);
	var py = dialog_y + ui(title_height);
	var pw = dialog_w - ui(padding + padding);
	var ph = dialog_h - ui(title_height + padding)
	
	draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
	sc_group.setFocusHover(sFOCUS, sHOVER);
	sc_group.draw(px, py);
	
	var bx = dialog_x + dialog_w - ui(32 + 16);
	var by = dialog_y + ui(16);
	
	if(type == CONNECT_TYPE.input) { 
		var _txt = __txtx("dialog_group_order_add", "Add separator");
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), mouse_ui, sHOVER, sFOCUS, _txt, THEME.add_16, 1, COLORS._main_value_positive) == 2) {
			array_push(node.attributes.input_display_list, [ "Separator", false ]);
			node.sortIO();
		}
	}
#endregion