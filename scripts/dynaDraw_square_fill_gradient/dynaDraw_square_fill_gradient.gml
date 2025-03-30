function dynaDraw_square_fill_gradient() : dynaDraw() constructor {
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color(_col);
		draw_set_alpha(_alp);
		
		if(round(_sx) <= 1 && round(_sy) <= 0) {
			draw_point(_x, _y);
			draw_set_alpha(1);
			return;
		}
		
		if(_ang == 0) {
			var x0 = _x - _sx / 2;
			var y0 = _y - _sy / 2;
			
			var x1 = _x + _sx / 2;
			var y1 = _y - _sy / 2;
			
			var x2 = _x - _sx / 2;
			var y2 = _y + _sy / 2;
			
			var x3 = _x + _sx / 2;
			var y3 = _y + _sy / 2;
			
		} else {
			var _p = point_rotate(-_sx / 2, -_sy / 2, 0, 0, _ang);
			var x0 = _x + _p[0];
			var y0 = _y + _p[1];
			
			var _p = point_rotate( _sx / 2, -_sy / 2, 0, 0, _ang);
			var x1 = _x + _p[0];
			var y1 = _y + _p[1];
			
			var _p = point_rotate(-_sx / 2,  _sy / 2, 0, 0, _ang);
			var x2 = _x + _p[0];
			var y2 = _y + _p[1];
			
			var _p = point_rotate( _sx / 2,  _sy / 2, 0, 0, _ang);
			var x3 = _x + _p[0];
			var y3 = _y + _p[1];
			
		}
		
		draw_triangle_color( x0, y0,  _x, _y,  x1, y1, c_black, _col, c_black, false );
		draw_triangle_color( x0, y0,  _x, _y,  x2, y2, c_black, _col, c_black, false );
		draw_triangle_color( x2, y2,  _x, _y,  x3, y3, c_black, _col, c_black, false );
		draw_triangle_color( x1, y1,  _x, _y,  x3, y3, c_black, _col, c_black, false );
		
		draw_set_alpha(1);
	}
	
	static deserialize = function(m) /*=>*/ {return self};
}