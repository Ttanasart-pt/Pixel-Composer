function Panel_Gradient() : PanelContent() constructor {
	title = __txt("Gradients");
	padding		 = 8;
	
	w = ui(320);
	h = ui(480);
	
	function onResize() { sp_gradient.resize(w - ui(padding + padding), h - ui(padding + padding)); }
	
	sp_gradient = new scrollPane(w - ui(padding + padding), h - ui(padding + padding), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var ww  = sp_gradient.surface_w;
		var hh  = 0;
		
		var amo = array_length(GRADIENTS);
		var col = max(1, floor(ww / ui(160)));
		var row = ceil(amo / col);
		
		var pd  = ui(6);
		var gw  = (ww + ui(8)) / col;
		var hg  = ui(26);
		var yy  = _y;
		
		for(var i = 0; i < row; i++) {
			for(var j = 0; j < col; j++) {
				var ind = i * col + j;
				if(ind >= amo) break;
			
				var gww     = gw - ui(8);
				var xx      = j * gw;
				var preset	= GRADIENTS[ind];
				var isHover = pHOVER && point_in_rectangle(_m[0], _m[1], xx, max(0, yy), xx + gww, min(sp_gradient.h, yy + hg));
				
				draw_sprite_stretched(THEME.ui_panel_bg, 3, xx, yy, gww, hg);
				
				preset.gradient.draw(xx, yy, gww, hg);
				draw_set_text(f_p2, fa_left, fa_center, c_white);
				
				if(_color_get_light(preset.gradient.keys[0].value) > 0.5) {
					draw_set_color(c_black);
					draw_text(xx + pd, yy + hg / 2, preset.name);
				} else
					draw_text_add(xx + pd, yy + hg / 2, preset.name);
				
				draw_sprite_stretched_add(THEME.ui_panel_fg, 1, xx, yy, gww, hg, c_white, 0.3);
				if(isHover) {
					sp_gradient.hover_content = true;
					draw_sprite_stretched_ext(THEME.ui_panel_fg, 1, xx, yy, gww, hg, COLORS._main_accent, 1);
				}
				
				if(isHover && mouse_press(mb_left, pFOCUS)) {
					DRAGGING = { type: "Gradient", data: preset.gradient }
					MESSAGE  = DRAGGING;
				} 
			}
			
			yy += hg + ui(6);
			hh += hg + ui(6);
		}
		
		return hh;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = ui(padding);
		var py = ui(padding);
		var pw = w - ui(padding + padding);
		var ph = h - ui(padding + padding);
	
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sp_gradient.setFocusHover(pFOCUS, pHOVER);
		sp_gradient.draw(px, py, mx - px, my - py);
		
		// var bx = w - ui(32 + 16);
		// var by = padding / 2 - ui(16 + !in_dialog * 2);
		
		// if(buttonInstant(THEME.button_hide, bx, by, ui(32), ui(32), [mx, my], pFOCUS, pHOVER, __txt("Refresh"), THEME.refresh_icon, 1, COLORS._main_icon) == 2) 
		// 	__initGradient();
	}
}