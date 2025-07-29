function __panel_scrollcontent() : PanelContent() constructor {
	title   = __txt("Panel");
	w = ui(640);
	h = ui(800);
	
	sc_content = new scrollPane(w - padding * 2, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var ww = sc_content.surface_w;
		var hh = sc_content.surface_h;
		var _h  = 0;
		var yy = _y;
		
		var focus = sc_content.active;
		var hover = sc_content.hover;
		
		
		return _h;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var sp = padding - ui(8);
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sc_content.verify(pw, ph);
		sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.draw(px, py, mx - px, my - py);
		
	}
} 