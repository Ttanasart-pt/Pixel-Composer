function Panel_Globalvar() : PanelContent() constructor {
	title = __txtx("panel_globalvar", "Global Variables");
	context_str = "Globalvar";
	showHeader  = false;
	
	title_height = 64;
	padding = 24;
		
	w = ui(320);
	h = ui(480);
	
	globalvar_viewer_init();
	drawWidgetInit();
	
	function onResize() {
		PANEL_PADDING
		
		contentPane.resize(w - ui(padding + padding), h - ui(title_height + padding));
	}
	
	contentPane = new scrollPane(w - ui(padding + padding), h - ui(title_height + padding), function(_y, _m) {
		var _hover = pHOVER && contentPane.hover;
		
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var hh = 0;
		var yy = _y;
		
		var gvh = globalvar_viewer_draw(0, yy, contentPane.surface_w, _m, pFOCUS, _hover, contentPane, x + ui(padding), y + ui(title_height));
		yy += gvh + ui(8);
		hh += gvh + ui(8);
			
		return hh;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		PANEL_PADDING
		PANEL_TITLE
		
		var px = ui(padding);
		var py = ui(title_height);
		var pw = w - ui(padding + padding);
		var ph = h - ui(title_height + padding);
		
		draw_sprite_stretched(THEME.ui_panel_bg, !in_dialog, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		contentPane.setFocusHover(pFOCUS, pHOVER);
		contentPane.draw(px, py, mx - px, my - py);
		
		var bx = w - ui(32 + 16);
		var by = title_height / 2 - ui(16 + !in_dialog * 2);
		
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txtx("panel_globalvar_add", "Add variable"), THEME.add, 1, COLORS._main_value_positive) == 2)
			GLOBAL_NODE.createValue();
		
		bx -= ui(32 + 4);
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txt("Edit"), var_editing? THEME.accept : THEME.gear,,,, 0.9) == 2)
			var_editing = !var_editing;
	}
}