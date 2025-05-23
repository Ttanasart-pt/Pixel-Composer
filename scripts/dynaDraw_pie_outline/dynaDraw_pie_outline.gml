function dynaDraw_pie_outline() : dynaDraw() constructor {
	
	parameters = [ "fill", "thickness" ];
	fill       = .5;
	thickness  = 1;
	editors    = [
		[ "Fill",      textBox_Number(function(n) /*=>*/ { fill      = n; updateNode(); }), function() /*=>*/ {return fill}      ],
		[ "Thickness", textBox_Number(function(n) /*=>*/ { thickness = n; updateNode(); }), function() /*=>*/ {return thickness} ],
	];
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color(_col);
		draw_set_alpha(_alp);
		
		var _fl = params[$ "fill"] ?? fill; params[$ "fill"] = fill;
		var _th = params[$ "thickness"] ?? thickness; params[$ "thickness"] = thickness;
		
		var _samp = 32;
		
		var _ast = _ang;
		var _asp = 360 * _fl / _samp;
		
		_sx /= 2;
		_sy /= 2;
		
		var nx, ny;
		var ox = _x + lengthdir_x(_sx, _ast);
		var oy = _y + lengthdir_y(_sy, _ast);
		draw_line_round(ox, oy, _x, _y, _th);
		
		repeat(_samp) {
			_ast += _asp;
			nx = _x + lengthdir_x(_sx, _ast);
			ny = _y + lengthdir_y(_sy, _ast);
			
			draw_line_round(ox, oy, nx, ny, _th);
			
			ox = nx;
			oy = ny;
		}
		
		draw_line_round(ox, oy, _x, _y, _th);
		draw_set_alpha(1);
	}
	
	static doSerialize = function(m) {
		m.fill      = fill;
		m.thickness = thickness;
	}
	
	static deserialize = function(m) { 
		fill      = m[$ "fill"] ?? fill;
		thickness = m[$ "thickness"] ?? thickness;
		return self; 
	}
}