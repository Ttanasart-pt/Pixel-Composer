function dynaDraw_circle_fill() : dynaDraw() constructor {
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color(_col);
		draw_set_alpha(_alp);
		draw_set_circle_precision(32);
		
		if(_sx != _sy) {
			draw_ellipse(_x - _sx / 2, _y - _sy / 2, _x + _sx / 2, _y + _sy / 2, false);
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
				draw_point( _x,     _y     );
				draw_point( _x - 1, _y     );
				draw_point( _x + 1, _y     );
				draw_point( _x,     _y + 1 );
				draw_point( _x,     _y - 1 );
				break;
				
			default : 
				draw_circle(_x, _y, _sx / 2 - 1, false);
				
				// draw_set_color(c_black);
				// draw_circle_border(_x + 1, _y + 1, _sx / 2 - 1, 2);
				break;
		}
		
		draw_set_alpha(1);
	}
	
	static doSerialize = function(m) {}
	
	static deserialize = function(m) { return self; }
}