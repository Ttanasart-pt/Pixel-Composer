function Panel_Gradient() : PanelContent() constructor {
	title = __txt("Gradients");
	
	w = ui(320);
	h = ui(480);
	
	function onResize() { sp_gradient.resize(w - padding * 2, h - padding * 2); }
	
	function drawGradientDirectory(_dir, _x, _y, _m) {
		var _hover = sp_gradient.hover;
		var _focus = sp_gradient.active;
		
		var ww  = sp_gradient.surface_w - _x;
		var gh  = ui(16);
		var nh  = ui(20);
		var pd  = ui(2);
		var hg  = nh + gh + pd;
		var hh  = 0;
		
		var lbh = ui(20);
		
		for( var i = 0, n = array_length(_dir.subDir); i < n; i++ ) {
			var _sub  = _dir.subDir[i];
			var _open = _sub[$ "expanded"] ?? true;
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, lbh);
			if(_hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + lbh)) {
				draw_sprite_stretched_ext(THEME.node_bg, 1, _x, _y, ww, lbh, COLORS._main_icon, 1);
				if(mouse_lpress(_focus)) {
					_open = !_open;
					_sub[$ "expanded"] = _open;
				}
			}
			
			draw_sprite_ui_uniform(THEME.arrow, _open * 3, _x + ui(12), _y + lbh/2, .8, COLORS._main_icon);
			draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text);
			draw_text_add(_x + ui(24), _y + lbh/2, _sub.name);
			
			hh += lbh + ui(4);
			_y += lbh + ui(4);
			
			if(!_open) continue;
			var _sh  = drawGradientDirectory(_sub, _x + ui(8), _y, _m);
			
			_y += _sh;
			hh += _sh;
		}
		
		for( var i = 0, n = array_length(_dir.content); i < n; i++ ) {
			var g = _dir.content[i];
			if(g.content == undefined)
				g.content = loadGradient(g.path);
			
			var _name = g.name;
			var _grad = g.content;
			
			if(!is(_grad, gradientObject)) continue;
			
			var isHover = _hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + ww, _y + hg);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, _x, _y, ww, hg);
			if(isHover) {
				sp_gradient.hover_content = true;
				draw_sprite_stretched_ext(THEME.node_bg, 1, _x, _y, ww, hg, COLORS._main_accent, 1);
			}
				
			draw_set_text(f_p4, fa_left, fa_top, COLORS._main_text);
			draw_text_add(_x + pd + ui(4), _y + ui(2), _name);
			_grad.draw(_x + pd, _y + nh, ww - pd * 2, gh);
			
			if(isHover && mouse_press(mb_left, _focus)) {
				// todo
			}
			
			_y += hg + ui(4);
			hh += hg + ui(4);
		}
		
		return hh;
	} 
	
	sp_gradient = new scrollPane(w - padding * 2, h - padding * 2, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var hh = drawGradientDirectory(GRADIENTS_FOLDER, 0, _y, _m);
		return hh;
	});
	
	function drawContent(panel) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
	
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		sp_gradient.setFocusHover(pFOCUS, pHOVER);
		sp_gradient.draw(px, py, mx - px, my - py);
	}
}