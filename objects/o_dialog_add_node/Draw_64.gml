/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
#endregion

#region search
	WIDGET_CURRENT = tb_search;
	
	if(search_string == "") {
		tb_search.focus = false;
		tb_search.hover = false;
		tb_search.sprite_index = 1;
		
		catagory_pane.active = sFOCUS;
		catagory_pane.draw(dialog_x + ui(14), dialog_y + ui(52));
	
		draw_sprite_stretched(THEME.ui_panel_bg, 0, dialog_x + ui(120), dialog_y + ui(52), dialog_w - ui(134), dialog_h - ui(66));
		content_pane.active = sFOCUS;
		content_pane.draw(dialog_x + ui(120), dialog_y + ui(52));
		
		node_selecting = 0;
	} else {
		tb_search.focus = true;
		tb_search.hover = true;
		draw_sprite_stretched(THEME.ui_panel_bg, 0, dialog_x + ui(14), dialog_y + ui(52), dialog_w - ui(28), dialog_h - ui(66));
		search_pane.active = sFOCUS;
		search_pane.draw(dialog_x + ui(16), dialog_y + ui(52));
	}
	
	tb_search.draw(dialog_x + ui(14), dialog_y + ui(14), dialog_w - ui(96), ui(32), search_string, mouse_ui);
	
	var bx = dialog_x + dialog_w - ui(44);
	var by = dialog_y + ui(16);
	var b = buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, 
		PREF_MAP[? "dialog_add_node_view"]? "List view" : "Grid view", THEME.view_mode, PREF_MAP[? "dialog_add_node_view"], COLORS._main_icon);
	if(b == 2) 
		PREF_MAP[? "dialog_add_node_view"] = !PREF_MAP[? "dialog_add_node_view"];
	
	bx -= ui(32);
	var b = buttonInstant(THEME.button_hide, bx, by, ui(28), ui(28), mouse_ui, sFOCUS, sHOVER, 
		PREF_MAP[? "dialog_add_node_grouping"]? "Group enabled" : "Group disabled", THEME.view_group, PREF_MAP[? "dialog_add_node_grouping"], COLORS._main_icon);
	if(b == 2)
		PREF_MAP[? "dialog_add_node_grouping"] = !PREF_MAP[? "dialog_add_node_grouping"];
#endregion

//#region dec
//	if(node_called) {
//		var jx = 0;
//		var jy = dialog_y + ui(26);
		
//		if(node_called.connect_type == JUNCTION_CONNECT.input) 
//			jx = dialog_x;
//		else 
//			jx = dialog_x + dialog_w;
//	}
//#endregion