function Panel_Note_Md(_data) : PanelContent() constructor {
	title = _data.title;
	w = min(ui(800), WIN_W * .8);
	h = ui(480);
	
	page_width = ui(0);
	pages      = [];
	gotoH2     = "";
	currH2     = 0;
	
	data       = _data.content;
	dataMd     = markdown_parse(data);
	
	draw_set_font(f_p3);
	for( var i = 0, n = array_length(dataMd); i < n; i++ ) {
		var _l = dataMd[i];
		if(!is(_l, md_h2)) continue;
		
		array_push(pages, _l);
		var rw = string_width(_l.txt) + ui(24);
		page_width = max(page_width, rw);
	}
	
	panel_width   = w - padding * 2 - page_width;
	panel_height  = h - padding * 2;
	
	sp_note = new scrollPane(panel_width, panel_height, function(_y, _m) {
		draw_clear_alpha(COLORS.dialog_splash_badge, 1);
		
		var xx = ui(8);
		var yy = ui(8) + _y;
		var ww = sp_note.surface_w - ui(16);
		var hh = markdown_draw(dataMd, xx, yy, ww);
		
		return hh + ui(64);
	});
	
	function drawContent(panel) {
		var _x = padding + ui(4);
		var _y = padding;
		var hg = line_get_height(f_p3, 8);
		
		draw_set_text(f_p3, fa_left, fa_top, COLORS._main_text);
		
		var sy0 = -sp_note.scroll_y;
		var sy1 = -sp_note.scroll_y + sp_note.surface_h;
		
		for( var i = 0, n = array_length(pages); i < n; i++ ) {
			var page = pages[i];
			var text = page.txt;
			var rw   = string_width(text);
			
			var y0   = pages[i].y + ui(16);
			var y1   = i + 1 < n? pages[i + 1].y : sp_note.content_h + ui(16);
			
			var px = _x - ui(8);
			var py = _y - ui(4);
			var pw = page_width - ui(8);
			var ph = hg;
			
			if(pHOVER && point_in_rectangle(mx, my, px, py, px + pw, py + ph - 1)) {
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, px, py, pw, ph, CDEF.main_white, 1);
				
				if(mouse_press(mb_left, pFOCUS))
					sp_note.scroll_y_to = -page.y;
			}
			
			var _inRange = (y1 > sy0) && (y0 < sy1);
			
			draw_set_color(_inRange? COLORS._main_text : COLORS._main_text_sub);
			draw_text(_x, _y, text);
				
			_y += hg;
		}
		
		panel_width   = w - padding * 2 - page_width;
		panel_height  = h - padding * 2;
		
		var px = padding + page_width;
		var py = padding;
		var pw = panel_width;
		var ph = panel_height;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		sp_note.verify(panel_width, panel_height);
		sp_note.setFocusHover(pFOCUS, pHOVER);
		sp_note.drawOffset(px, py, mx, my);
		
	}
}