function dynaDraw_square_fill() : dynaDraw() constructor {
	path = "dynaDraw_square_fill";
	
	static getWidth  = function() /*=>*/ {return 1};
	static getHeight = function() /*=>*/ {return 1};
	static getFormat = function() /*=>*/ {return surface_rgba8unorm};

	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color(_col);
		draw_set_alpha(_alp);
		
		if(round(_sx) <= 1 && round(_sy) <= 0) {
			draw_point(_x, _y);
			draw_set_alpha(1);
			return;
		}
				
		draw_rectangle(_x - _sx / 2, _y - _sy / 2, _x + _sx / 2, _y + _sy / 2, false);
		draw_set_alpha(1);
	}
}