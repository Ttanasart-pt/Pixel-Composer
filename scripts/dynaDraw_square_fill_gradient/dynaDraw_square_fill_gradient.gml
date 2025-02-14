function dynaDraw_square_fill_gradient() : dynaDraw() constructor {
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color(_col);
		draw_set_alpha(_alp);
		
		if(round(_sx) <= 1 && round(_sy) <= 0) {
			draw_point(_x, _y);
			draw_set_alpha(1);
			return;
		}
		
		var x0 = _x - _sx / 2;
		var y0 = _y - _sy / 2;
		var x1 = _x + _sx / 2;
		var y1 = _y + _sy / 2;
		
		draw_triangle_color( x0, y0,  _x, _y,  x1, y0, c_black, _col, c_black, false );
		draw_triangle_color( x1, y0,  _x, _y,  x1, y1, c_black, _col, c_black, false );
		draw_triangle_color( x1, y1,  _x, _y,  x0, y1, c_black, _col, c_black, false );
		draw_triangle_color( x0, y1,  _x, _y,  x0, y0, c_black, _col, c_black, false );
		
		draw_set_alpha(1);
	}
	
	static doSerialize = function(m) {}
	
	static deserialize = function(m) { return self; }
}