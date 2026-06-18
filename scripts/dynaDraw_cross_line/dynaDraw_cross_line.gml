function dynaDraw_cross_line() : dynaDraw() constructor {
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color_alpha(_col, _alp);
		
		draw_line(_x - _sx/2, _y, _x + _sx/2, _y);
		draw_line(_x, _y - _sy/2, _x, _y + _sy/2);
		
		draw_set_alpha(1);
	}
	
	static doSerialize = function(m) {}
	
	static deserialize = function(m) { return self; }
}