function Panel_Palette() : PanelContent() constructor {
	title = __txt("Palettes");
	padding = 8;
	
	w = ui(320);
	h = ui(480);
	
	view_mode = 0;
	
	color_dragging = noone;
	
	function onResize() {
		sp_palettes.resize(w - ui(padding + padding), h - ui(padding + padding));
	}
	
	sp_palettes = new scrollPane(w - ui(padding + padding), h - ui(padding + padding), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		var ww  = sp_palettes.surface_w;
		var hh  = ui(28);
		var _gs = ui(24);
		switch(view_mode) {
			case 0 : _gs = ui(24); break;	
			case 1 : _gs = ui(32); break;	
			case 2 : _gs = ui(16); break;	
		}
		var _height;
		var yy  = _y;
		var cur = CURRENT_COLOR;
		
		for(var i = 0; i < array_length(PALETTES); i++) {
			var preset	= PALETTES[i];
			var pre_amo = array_length(preset.palette);
			var col     = floor((ww - ui(20)) / _gs);
			var row     = ceil(pre_amo / col);
			
			_height = ui(34) + row * _gs;
			
			var isHover = pHOVER && point_in_rectangle(_m[0], _m[1], 0, max(0, yy), ww, min(sp_palettes.h, yy + _height));
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, 0, yy, ww, _height);
			if(isHover) 
				draw_sprite_stretched_ext(THEME.node_active, 1, 0, yy, ww, _height, COLORS._main_accent, 1);
			
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text(ui(10), yy + ui(2), preset.name);
			drawPaletteGrid(preset.palette, ui(10), yy + ui(24), ww - ui(20), _gs, cur);
			
			if(isHover) {
				if(mouse_press(mb_left, pFOCUS)) {
					if(point_in_rectangle(_m[0], _m[1], ui(10), yy + ui(24), ww - ui(10), yy + ui(24) + _height)) {
						var m_ax = _m[0] - ui(10);
						var m_ay = _m[1] - (yy + ui(24));
					
						var m_gx = floor(m_ax / _gs);
						var m_gy = floor(m_ay / _gs);
						
						var _index = m_gy * col + m_gx;
						if(_index < pre_amo && _index >= 0) {
							CURRENT_COLOR = array_safe_get_fast(preset.palette, _index);
							
							DRAGGING = {
								type: "Color",
								data: array_safe_get_fast(preset.palette, _index)
							}
							MESSAGE = DRAGGING;
						}
					} else if(point_in_rectangle(_m[0], _m[1], ui(10), yy, ww - ui(10), yy + ui(24))) {
						DRAGGING = {
							type: "Palette",
							data: preset.palette
						}
						MESSAGE = DRAGGING;
					}
				}
				
				if(mouse_press(mb_right, pFOCUS)) {
					hovering = preset;
					
					menuCall("palette_window_preset_menu",,, [
						menuItem(__txt("Refresh"), function() { 
							__initPalette();
						}),
						menuItem(__txtx("palette_change_preview_size", "Change preview size"), function() { 
							view_mode = (view_mode + 1) % 3;
						}),
						-1, 
						menuItem(__txtx("palette_editor_set_default", "Set as default"), function() { 
							PROJECT.setPalette(array_clone(hovering.palette));
						}),
						menuItem(__txtx("palette_editor_delete", "Delete palette"), function() { 
							file_delete(hovering.path); 
							__initPalette();
						}),
					]);
				}
			} 
			
			yy += _height + ui(8);
			hh += _height + ui(8);
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
		
		sp_palettes.setFocusHover(pFOCUS, pHOVER);
		sp_palettes.draw(px, py, mx - px, my - py);
		
	}
}