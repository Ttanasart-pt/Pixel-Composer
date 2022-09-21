/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(FOCUS == self)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region search
	TEXTBOX_ACTIVE = tb_search;
	
	if(search_string == "") {
		tb_search.focus = false;
		tb_search.hover = false;
		tb_search.sprite_index = 1;
		
		catagory_pane.active = FOCUS == self;
		catagory_pane.draw(dialog_x + 14, dialog_y + 52);
	
		draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + 120, dialog_y + 52, dialog_w - 120 - 14, dialog_h - 66);
		content_pane.active = FOCUS == self;
		content_pane.draw(dialog_x + 120, dialog_y + 52);
		
		node_selecting = 0;
	} else {
		tb_search.focus = true;
		tb_search.hover = true;
		draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + 14, dialog_y + 52, dialog_w - 28, dialog_h - 66);
		search_pane.active = FOCUS == self;
		search_pane.draw(dialog_x + 16, dialog_y + 52);
	}
	
	tb_search.draw(dialog_x + 14, dialog_y + 14, dialog_w - 64, 32, search_string, [mouse_mx, mouse_my]);
	var bx = dialog_x + dialog_w - 44;
	var by = dialog_y + 16;
	var b = buttonInstant(s_button_hide, bx, by, 28, 28, [mouse_mx, mouse_my], FOCUS == self, HOVER == self, 
		ADD_NODE_MODE == 1? "List view" : "Grid view", s_add_node_view, ADD_NODE_MODE, c_ui_blue_grey);
	if(b == 2) 
		ADD_NODE_MODE = !ADD_NODE_MODE;
#endregion