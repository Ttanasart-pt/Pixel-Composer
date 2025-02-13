function dynaDraw_circle_outline() : dynaDraw() constructor {
	path = "dynaDraw_circle_outline";
	
	static getWidth  = function() /*=>*/ {return 1};
	static getHeight = function() /*=>*/ {return 1};
	static getFormat = function() /*=>*/ {return surface_rgba8unorm};

	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color(_col);
		draw_set_alpha(_alp);
		draw_set_circle_precision(32);
		
		if(_sx != _sy) {
			draw_ellipse(_x - _sx / 2, _y - _sy / 2, _x + _sx / 2, _y + _sy / 2, true);
			draw_set_alpha(1);
			return;
		}
		
		switch(round(_sx)) {
			case 0 : 
			case 1 : 
				draw_point( _x, _y );
				break;
				
			case 2 : 
				draw_point( _x + 0, _y + 0 );
				draw_point( _x + 1, _y + 0 );
				draw_point( _x + 0, _y + 1 );
				draw_point( _x + 1, _y + 1 );
				break;
				
			case 3 : 
				draw_point( _x - 1, _y     );
				draw_point( _x + 1, _y     );
				draw_point( _x,     _y + 1 );
				draw_point( _x,     _y - 1 );
				break;
				
			default : 
				draw_circle(_x, _y, _sx / 2 - 1, true);
				break;
		}
		
		draw_set_alpha(1);
	}
}
