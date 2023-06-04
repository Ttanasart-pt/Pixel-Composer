/// @description init
#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
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
	
	draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text_title);
	draw_text(dialog_x + ui(16), dialog_y + ui(16), __txtx("assets", "Assets"));
	
	draw_sprite_stretched(THEME.ui_panel_bg, 0, dialog_x + ui(16), dialog_y + ui(48), folderW - ui(8), dialog_h - ui(64));
	draw_sprite_stretched(THEME.ui_panel_bg, 0, dialog_x + ui(16) + folderW, dialog_y + ui(16), dialog_w - ui(32) - folderW, dialog_h - ui(32));
	
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
	
	folderPane.setActiveFocus(sHOVER, sFOCUS);
	folderPane.draw(dialog_x + ui(16), dialog_y + ui(48));
	
	contentPane.setActiveFocus(sHOVER, sFOCUS);
	contentPane.draw(dialog_x + ui(20) + folderW, dialog_y + ui(16));
#endregion