/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
#endregion

#region text
	var bh = line_get_height(f_p0) + ui(8);
	var _x = dialog_x + ui(24);
	var _y = dialog_y + ui(16);
	var hd = ui(48);
	
	draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text);
	
	for( var i = 0, n = array_length(pages); i < n; i++ ) {
		draw_set_font(f_p0b);
		var r  = __txt(pages[i]);
		var rw = string_width(r);
		
		if(buttonInstant(THEME.button_hide_fill, _x - ui(8), _y - ui(4), rw + ui(16), bh, [ mouse_mx, mouse_my ], sHOVER, sFOCUS) == 2)
			page = i;
		
		draw_set_font(i == page? f_p0b : f_p0);
		draw_set_color(i == page? COLORS._main_text : COLORS._main_text_sub);
		draw_text(_x, _y, r);
			
		_x += rw + ui(24);
	}
		
	draw_sprite_stretched(THEME.ui_panel_bg, 1, dialog_x + padding, dialog_y + hd, dialog_w - padding * 2, dialog_h - hd - padding);
	
	content_w = dialog_w - (padding + ui(8)) * 2;
	content_h = dialog_h - ui(48 + 16) - padding;
	
	if(page == 0) {
		sp_note.setFocusHover(sFOCUS, sHOVER);
		sp_note.verify(content_w, content_h);
		sp_note.draw(dialog_x + padding + ui(8), dialog_y + hd + ui(8));
		
	} else if(page == 1) {
		sp_dl.setFocusHover(sFOCUS, sHOVER);
		sp_dl.verify(content_w, content_h);
		sp_dl.draw(dialog_x + padding + ui(8), dialog_y + hd + ui(8));
		
	}
#endregion