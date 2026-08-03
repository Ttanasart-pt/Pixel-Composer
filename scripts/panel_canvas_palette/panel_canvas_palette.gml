function Panel_Canvas_Palette() : PanelContent() constructor {
	context_str = "Canvas";
	title       = "Canvas Palette";
	auto_pin    = true;
	
	w = ui(32);
	h = ui(800);
	
	min_w  = ui(160);
	
	grid_size = ui(20);
	
	canvas  = undefined;
	palette = DEF_PALETTE;
	paletteName = "Project";
	
	palette_selector = new buttonPalette(function(p) /*=>*/ { 
		palette     = p.palette; 
		paletteName = p.preset;
	}).setOutputName(true).setExpandable(false);
	
	sc_content = new scrollPane(w - padding * 2, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var ww = sc_content.surface_w;
		var hh = sc_content.surface_h;
		var _h  = 0;
		var yy = _y;
		
		var focus = sc_content.active;
		var hover = sc_content.hover;
		
		var _amo = array_length(palette);
		var _bs  = grid_size;
		var _pd  = ui(1);
		
		var _col = max(1, floor(ww   / _bs));
		var _row = ceil(_amo / _col);
		
		_h = _bs * _row;
		
		for( var i = 0; i < _amo; i++ ) {
			var col = palette[i];
			
			var c = i % _col;
			var r = floor(i / _col);
			
			var cx = c * _bs;
			var cy = _y + r * _bs;
			
			var sel = canvas.tool_color == col;
			
			if(sel) {
				draw_sprite_stretched_ext(THEME.box_r2, 0, cx + _pd, cy + _pd, _bs - _pd * 2, _bs - _pd * 2, col);
				BLEND_SUBTRACT
				draw_sprite_stretched_ext(THEME.box_r2, 2, cx + _pd + 1, cy + _pd + 1, _bs - _pd * 2 - 2, _bs - _pd * 2 - 2, c_white);
				BLEND_NORMAL
				draw_sprite_stretched_ext(THEME.box_r2, 1, cx + _pd, cy + _pd, _bs - _pd * 2, _bs - _pd * 2, col);
				
			} else
				draw_sprite_stretched_ext(THEME.box_r2, 0, cx + _pd, cy + _pd, _bs - _pd * 2, _bs - _pd * 2, col);
			
			var hov = hover && point_in_rectangle(_m[0], _m[1], cx, cy, cx + _bs, cy + _bs);
			if(hov) {
				draw_sprite_stretched_add(THEME.box_r2, 1, cx + _pd, cy + _pd, _bs - _pd * 2, _bs - _pd * 2, c_white, .25);
				
				if(mouse_lclick(focus))
					canvas.tool_color = col;
			}
			
		}
		
		if(hover && key_mod_press(CTRL) && MOUSE_WHEEL != 0)
			grid_size = clamp(grid_size + MOUSE_WHEEL * ui(4), ui(16), ui(64));
		
		return _h;
	});
	
	function drawContent(panel) {
		if(!is(canvas, Panel_Canvas)) return;
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		var sh = ui(32);
		palette_selector.presetName = paletteName;
		palette_selector.setFocusHover(pFOCUS, pHOVER);
		palette_selector.drawParam(new widgetParam(px, py, pw, sh, palette, undefined, [mx,my], x, y));
		
		py += sh + ui(16);
		ph -= sh + ui(16);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sc_content.verify(pw, ph);
		sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.draw(px, py, mx - px, my - py);
		
	}
}