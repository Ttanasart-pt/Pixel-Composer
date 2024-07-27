function Panel_Gradient() : PanelContent() constructor {
	title = __txt("Gradients");
	showHeader	 = false;
	title_height = 64;
	padding		 = 20;
	
	w = ui(320);
	h = ui(480);
	
	function onResize() {
		PANEL_PADDING
		
		sp_gradient.resize(w - ui(padding + padding), h - ui(title_height + padding));
	}
	
	sp_gradient = new scrollPane(w - ui(padding + padding), h - ui(title_height + padding), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var ww  = sp_gradient.surface_w;
		var hh  = 0;
		
		var amo = array_length(GRADIENTS);
		var col = floor(ww / ui(160));
		var row = ceil(amo / col);
		
		var gw  = (ww + ui(8)) / col;
		var gh  = ui(16);
		
		var hg  = ui(24 + 8) + gh;
		var yy  = _y;
		
		for(var i = 0; i < row; i++) {
			for(var j = 0; j < col; j++) {
				var ind = i * col + j;
				if(ind >= amo) break;
			
				var xx = j * gw;
				var preset	= GRADIENTS[ind];
				var isHover = pHOVER && point_in_rectangle(_m[0], _m[1], xx, max(0, yy), xx + gw - ui(8), min(sp_gradient.h, yy + hg));
			
				draw_sprite_stretched(THEME.ui_panel_bg, 3, xx, yy, gw - ui(8), hg);
				if(isHover) 
					draw_sprite_stretched_ext(THEME.node_active, 1, xx, yy, gw - ui(8), hg, COLORS._main_accent, 1);
			
				draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
				draw_text(xx + ui(10), yy + ui(2), preset.name);
				preset.gradient.draw(xx + ui(10), yy + ui(24), gw - ui(28), gh);
			
				if(isHover && mouse_press(mb_left, pFOCUS)) {
					DRAGGING = {
						type: "Gradient",
						data: preset.gradient
					}
					MESSAGE = DRAGGING;
				} 
			}
			yy += hg + ui(8);
			hh += hg + ui(8);
		}
		
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
	
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sp_gradient.setFocusHover(pFOCUS, pHOVER);
		sp_gradient.draw(px, py, mx - px, my - py);
		
		var bx = w - ui(32 + 16);
		var by = title_height / 2 - ui(16 + !in_dialog * 2);
		
		if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txt("Refresh"), THEME.refresh_icon, 1, COLORS._main_icon) == 2) 
			__initGradient();
	}
}