function Panel_Globalvar() : PanelContent() constructor {
	title       = __txtx("panel_globalvar", "Global Variables");
	context_str = "Globalvar";
	auto_pin    = true;
	
	w = ui(320);
	h = ui(480);
	
	global_drawer = new GlobalVarDrawer();
	
	function onResize() { contentPane.resize(w - padding * 2, h - padding * 2 - ui(28)); }
	
	contentPane = new scrollPane(w - padding * 2, h - padding * 2 - ui(28), function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		
		var _hover = pHOVER && contentPane.hover;
		var hh = 0;
		var yy = _y;
		
        var glPar = global_drawer.draw(ui(8), yy, contentPane.surface_w - ui(16), _m, pFOCUS, _hover, contentPane, x + padding, y + padding);
        var gvh   = glPar[0];
		if(glPar[1]) contentPane.hover_content = true;
					
		yy += gvh + ui(8);
		hh += gvh + ui(8);
			
		return hh;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2 - ui(28);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		contentPane.setFocusHover(pFOCUS, pHOVER);
		contentPane.draw(px, py, mx - px, my - py);
		
		var _add_h = ui(24);
		var _bx    = 0;
		var _by    = h - _add_h;
		var _ww    = w;
		
		if(global_drawer.editing) {
			var _bw  = _ww / 2 - ui(4);
			var _hov = pHOVER && point_in_rectangle(mx, my, _bx, _by, _bx + _bw, _by + _add_h);
			
			draw_sprite_stretched_ext(THEME.ui_panel, 0, _bx, _by, _bw, _add_h, _hov? COLORS._main_value_positive : COLORS._main_icon, .3 + _hov * .1);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _bw, _add_h, _hov? COLORS._main_value_positive : COLORS._main_icon, .6 + _hov * .25);
			draw_set_text(f_p2, fa_center, fa_center, _hov? COLORS._main_value_positive : COLORS._main_icon_light);
			draw_text_add(_bx + _bw / 2, _by + _add_h / 2, __txt("Add"));
			
			contentPane.hover_content |= _hov;
			if(mouse_press(mb_left, _hov && pFOCUS))
				PROJECT.globalNode.createValue();
			
			_bx += _bw + ui(8);
			var _hov = pHOVER && point_in_rectangle(mx, my, _bx, _by, _bx + _bw, _by + _add_h);
			
			draw_sprite_stretched_ext(THEME.ui_panel, 0, _bx, _by, _bw, _add_h, _hov? COLORS._main_icon_light : COLORS._main_icon, .3 + _hov * .1);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _bw, _add_h, _hov? COLORS._main_icon_light : COLORS._main_icon, .6 + _hov * .25);
			draw_set_text(f_p2, fa_center, fa_center, _hov? COLORS._main_icon_light : COLORS._main_icon_light);
			draw_text_add(_bx + _bw / 2, _by + _add_h / 2, __txt("Apply"));
			
			contentPane.hover_content |= _hov;
			if(mouse_press(mb_left, _hov && pFOCUS))
				global_drawer.editing = false;
				
		} else {
			var _hov   = pHOVER && point_in_rectangle(mx, my, _bx, _by, _ww, _by + _add_h);
			
			draw_sprite_stretched_ext(THEME.ui_panel, 0, _bx, _by, _ww, _add_h, _hov? COLORS._main_value_positive : COLORS._main_icon, .3 + _hov * .1);
			draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _ww, _add_h, _hov? COLORS._main_value_positive : COLORS._main_icon, .6 + _hov * .25);
			draw_set_text(f_p2, fa_center, fa_center, _hov? COLORS._main_value_positive : COLORS._main_icon_light);
			draw_text_add(_bx + _ww / 2, _by + _add_h / 2, __txt("Edit"));
			
			contentPane.hover_content |= _hov;
			if(mouse_press(mb_left, _hov && pFOCUS))
				global_drawer.editing = true;
		}
		
	}
}