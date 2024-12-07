function tooltipRecentFile(path, _x, _y, _w, _h) constructor {
	self.path   = path;
	x = _x;
	y = _y;
	w = _w;
	h = _h;
	
	static drawTooltip = function() {
		var fname = filename_name_only(path);
		var fdir  = filename_dir(path);
		
		draw_set_font(f_p0b);
		var _w1 = string_width(fname);
		var _h1 = string_height(fname);
		
		draw_set_font(f_p2);
		var _w2 = string_width(fdir);
		var _h2 = string_height(fdir);
		
		var tw  = max(w, _w1, _w2);
		var th  = _h1 + ui(2) + _h2;
		
		var mx = x;
		var my = y;
		
		draw_sprite_stretched(THEME.ui_panel_bg,  1, mx, my, tw + ui(24), th + ui(14));
		draw_sprite_stretched_ext(THEME.ui_panel, 1, mx, my, tw + ui(24), th + ui(14), COLORS._main_accent, 1);
		
		var tx = mx + ui(12);
		var ty = my + ui(6);
		
		draw_set_text(f_p0b, fa_left, fa_top, COLORS._main_text_inner);
		draw_text(tx, ty, fname);
	
		ty += _h1 + ui(2);
		draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
		draw_text(tx, ty, fdir);
	}
}