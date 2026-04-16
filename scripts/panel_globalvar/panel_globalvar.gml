function Panel_Globalvar() : PanelContent() constructor {
	title       = __txt("panel_globalvar", "Global Variables");
	context_str = "Globalvar";
	auto_pin    = true;
	
	w = ui(320);
	h = ui(480);
	
	global_drawer = new GlobalVarDrawer();
	
	contentPane = new scrollPane(w - padding * 2, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var _hover = pHOVER && contentPane.hover;
		var hh = 0;
		var yy = _y;
		
		var gx = ui(8);
		var gy = yy;
		var gw = contentPane.surface_w - ui(16);
		
		var rx = x + padding;
		var ry = y + padding;
		
        var glPar = global_drawer.draw(gx, gy, gw, _m, pFOCUS, _hover, contentPane, rx, ry);
        var gvh   = glPar[0];
		if(glPar[1]) contentPane.hover_content = true;
					
		yy += gvh + ui(8);
		hh += gvh + ui(8);
			
		return hh;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var sp = padding - ui(8);
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		contentPane.verify(pw, ph);
		contentPane.setToolRect(global_drawer.editing? 2 : 1);
		contentPane.setFocusHover(pFOCUS, pHOVER);
		contentPane.drawOffset(px, py, mx, my);
		
    	var m  = [mx,my];
    	var bb = THEME.button_hide_fill;
		var bs = ui(24);
		var bx = px + pw + ui(8) - bs;
		var by = py - ui(8);
		
		if(global_drawer.editing) {
			var bc = COLORS._main_value_positive;
			if(buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Apply", THEME.accept_16, 0, bc, 1, 1) == 2)
				global_drawer.editing = false;
				
			bx -= bs + ui(2);
			var bc = COLORS._main_value_positive;
			if(buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Add", THEME.add_16, 0, bc, 1, 1) == 2)
				PROJECT.globalNode.createValue();
				
		} else {
			var bc = COLORS._main_icon;
			if(buttonInstant(bb, bx, by, bs, bs, m, pHOVER, pFOCUS, "Edit", THEME.gear_16, 0, bc, 1, 1) == 2)
				global_drawer.editing = true;
		}
	}
}