/// @description init
#region base UI
	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
#endregion

#region draw
	if(folderW_dragging) {
		var w = folderW_drag_sx + (mouse_mx - folderW_drag_mx);
		w = clamp(w, ui(200), dialog_w - ui(128));
		
		folderW = w;
		onResize();
		
		if(mouse_check_button_released(mb_left)) 
			folderW_dragging = -1;
	}
	
	draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(16), dialog_y + ui(16), __txt("Assets"));
	
	//draw_sprite_stretched(THEME.ui_panel_bg, 1, dialog_x + ui(16), dialog_y + ui(48), folderW - ui(24), dialog_h - ui(64));
	draw_sprite_stretched(THEME.ui_panel_bg, 1, dialog_x + ui(12 - 4) + folderW, dialog_y + ui(16), dialog_w - ui(28) - folderW, dialog_h - ui(32));
	
	var dx0 = dialog_x + ui(16) + folderW - ui(8);
	var dx1 = dialog_x + ui(16) + folderW;
	var dy0 = dialog_y + ui(48);
	var dy1 = dialog_y + dialog_h - ui(16);
	
	if(point_in_rectangle(mouse_mx, mouse_my, dx0, dy0, dx1, dy1)) {
		CURSOR = cr_size_we;
		if(mouse_click(mb_left, sFOCUS)) {
			folderW_dragging = true;
			folderW_drag_mx = mouse_mx;
			folderW_drag_sx = folderW;
		}
	}
	
	folderPane.setFocusHover(sFOCUS, sHOVER);
	folderPane.draw(dialog_x + ui(12), dialog_y + ui(48));
	
	contentPane.setFocusHover(sFOCUS, sHOVER);
	contentPane.draw(dialog_x + ui(12 - 4) + folderW, dialog_y + ui(16));
#endregion