/// @description init
#region base UI
	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
#endregion

#region draw
	if(folderW_dragging) {
		var w = folderW_drag_sx + (mouse_mx - folderW_drag_mx);
		w = clamp(w, ui(128), dialog_w - ui(128));
		
		folderW = w;
		onResize();
		
		if(mouse_lrelease(true, true)) 
			folderW_dragging = -1;
	}
	
	draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), __txt("Assets"));
	
	var _fld_x = dialog_x + ui(12);
	folderPane.setFocusHover(sFOCUS, sHOVER);
	folderPane.draw(_fld_x, dialog_y + ui(48));
	
	var _cnt_x = _fld_x + folderW - ui(4);
	var dx0 = _cnt_x - ui(8);
	var dx1 = _cnt_x;
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
	
	draw_sprite_stretched(THEME.ui_panel_bg, 1, _cnt_x, dialog_y + ui(12), content_w + ui(6), dialog_h - ui(24));
	
	contentPane.setFocusHover(sFOCUS, sHOVER);
	contentPane.draw(_cnt_x, dialog_y + ui(12));
#endregion