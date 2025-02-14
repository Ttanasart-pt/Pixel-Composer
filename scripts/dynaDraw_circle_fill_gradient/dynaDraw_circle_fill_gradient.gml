function dynaDraw_circle_fill_gradient() : dynaDraw() constructor {
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_alpha(_alp);
		draw_set_circle_precision(32);
		
		if(_sx != _sy) {
			draw_ellipse_color(_x - _sx / 2, _y - _sy / 2, _x + _sx / 2, _y + _sy / 2, _col, c_black, false);
			draw_set_alpha(1);
			return;
		}
		
		draw_set_color(_col);
		
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
				draw_point( _x, _y );
				
				draw_set_color(c_black);
				draw_point( _x - 1, _y     );
				draw_point( _x + 1, _y     );
				draw_point( _x,     _y + 1 );
				draw_point( _x,     _y - 1 );
				break;
				
			default : 
				draw_circle_color(_x, _y, _sx / 2 - 1, _col, c_black, false);
				break;
		}
		
		draw_set_alpha(1);
	}
	
	static doSerialize = function(m) {}
	
	static deserialize = function(m) { return self; }
}