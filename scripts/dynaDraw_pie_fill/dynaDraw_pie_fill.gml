function dynaDraw_pie_fill() : dynaDraw() constructor {
	
	parameters = [ "fill" ];
	fill       = .5;
	editors    = [
		[ "Fill", textBox_Number(function(n) /*=>*/ { fill = n; updateNode(); }), function() /*=>*/ {return fill} ],
	];
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color(_col);
		draw_set_alpha(_alp);
		
		var _fl = params[$ "fill"] ?? fill; params[$ "fill"] = fill;
		
		var _samp = 32;
		
		var _ast = _ang;
		var _asp = 360 * _fl / _samp;
		
		_sx /= 2;
		_sy /= 2;
		
		var nx, ny;
		var ox = _x + lengthdir_x(_sx, _ast);
		var oy = _y + lengthdir_y(_sy, _ast);
		
		repeat(_samp) {
			_ast += _asp;
			nx = _x + lengthdir_x(_sx, _ast);
			ny = _y + lengthdir_y(_sy, _ast);
			
			draw_triangle(_x, _y, ox, oy, nx, ny, false);
			
			ox = nx;
			oy = ny;
		}
		
		draw_set_alpha(1);
	}
	
	static doSerialize = function(m) {
		m.fill = fill;
	}
	
	static deserialize = function(m) { 
		fill = m[$ "fill"] ?? fill;
		return self; 
	}
}