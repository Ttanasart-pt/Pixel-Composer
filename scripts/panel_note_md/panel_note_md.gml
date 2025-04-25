function Panel_Note_Md(_data) : PanelContent() constructor {
	title = _data.title;
	w = ui(640);
	h = ui(480);
	
	data   = _data.content;
	dataMd = markdown_parse(data);
	
	panel_width   = w - padding * 2;
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
			
		panel_width   = w - padding * 2;
		panel_height  = h - padding * 2;
		
		var px = padding;
		var py = padding;
		var pw = panel_width;
		var ph = panel_height;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		sp_note.verify(panel_width, panel_height);
		sp_note.setFocusHover(pFOCUS, pHOVER);
		sp_note.drawOffset(px, py, mx, my);
		
	}
}