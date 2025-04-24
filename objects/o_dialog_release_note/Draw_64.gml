/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
#endregion

#region text
	var _x = dialog_x + ui(16);
	var _y = dialog_y + ui(16);
	var hg = line_get_height(f_p1, 8);
	
	draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text);
	
	for( var i = 0, n = array_length(pages); i < n; i++ ) {
		draw_set_font(f_p0b);
		var r  = __txt(pages[i]);
		var rw = string_width(r);
		
		var px = _x - ui(8);
		var py = _y - ui(4);
		var pw = page_width - ui(16);
		var ph = hg;
		
		if(sHOVER && point_in_rectangle(mouse_mx, mouse_my, px, py, px + pw, py + ph - 1)) {
			draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, px, py, pw, ph, CDEF.main_white, 1);
			
			if(i != page && mouse_press(mb_left, sFOCUS))
				page = i;
		}
	
		draw_set_font(i == page? f_p1b : f_p1);
		draw_set_color(i == page? COLORS._main_text : COLORS._main_text_sub);
		draw_text(_x, _y, r);
			
		_y += hg;
	}
	
	var _px = dialog_x + page_width;
	var _py = dialog_y + padding;
	var _pw = dialog_w - padding - page_width;
	var _ph = dialog_h - padding - padding;
	
	draw_sprite_stretched(THEME.ui_panel_bg, 1, _px, _py, _pw, _ph);
	
	content_w = _pw - ui(16);
	content_h = _ph - ui(16);
	
	if(page == 0) {
		sp_note.setFocusHover(sFOCUS, sHOVER);
		sp_note.verify(content_w, content_h);
		sp_note.draw(_px + ui(8), _py + ui(8));
		
	} else if(page == 1) {
		sp_dl.setFocusHover(sFOCUS, sHOVER);
		sp_dl.verify(content_w, content_h);
		sp_dl.draw(_px + ui(8), _py + ui(8));
		
	}
#endregion