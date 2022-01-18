/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(FOCUS == self)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region search
	tb_search.hover = true;
	tb_search.focus = true;
	TEXTBOX_ACTIVE = tb_search;
	 
	if(search_string == "") {
		tb_search.editText();
		
		catagory_pane.active = FOCUS == self;
		catagory_pane.draw(dialog_x + 14, dialog_y + 14);
	
		draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + 120, dialog_y + 14, dialog_w - 120 - 14, dialog_h - 28);
		content_pane.active = FOCUS == self;
		content_pane.draw(dialog_x + 120, dialog_y + 14);
		
		node_selecting = 0;
	} else {
		tb_search.draw(dialog_x + 14, dialog_y + 14, dialog_w - 28, 32, search_string, [mouse_mx, mouse_my]);
		
		draw_sprite_stretched(s_ui_panel_bg, 0, dialog_x + 14, dialog_y + 52, dialog_w - 28, dialog_h - 52 - 14);
		search_pane.active = FOCUS == self;
		search_pane.draw(dialog_x + 16, dialog_y + 52);
	}
#endregion