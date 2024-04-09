/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(sFOCUS)
		DIALOG_DRAW_FOCUS
#endregion

#region text
	
	var bh = line_get_height(f_p0) + ui(8);
	var _x = dialog_x + ui(24);
	var _y = dialog_y + ui(16);
	
	for( var i = 0, n = array_length(pages); i < n; i++ ) {
		var r  = __txt(pages[i]);
		var rw = string_width(r);
		
		if(buttonInstant(THEME.button_hide_fill, _x - ui(8), _y - ui(4), rw + ui(20), bh, [ mouse_mx, mouse_my ], sFOCUS, sHOVER) == 2)
			page = i;
		
		draw_set_text(f_p0b, fa_left, fa_top, i == page? COLORS._main_text : COLORS._main_text_sub);
		draw_text(_x, _y, r);
			
		_x += string_width(r) + ui(24);
	}
		
	draw_sprite_stretched(THEME.ui_panel_bg, 1, dialog_x + ui(24), dialog_y + ui(48), dialog_w - ui(48), dialog_h - ui(72));
	
	if(page == 0) {
		sp_note.setFocusHover(sFOCUS, sHOVER);
		sp_note.draw(dialog_x + ui(40), dialog_y + ui(56));
		
	} else if(page == 1) {
		sp_dl.setFocusHover(sFOCUS, sHOVER);
		sp_dl.draw(dialog_x + ui(40), dialog_y + ui(56));
		
	}
#endregion