function dynaDraw_spiral() : dynaDraw() constructor {
	
	parameters = [ "sides", "thickness", "gap" ];
	sides      = 6;
	thickness  = 4;
	gap        = 2;
	editors    = [
		[ "Sides",     textBox_Number(function(n) /*=>*/ { sides     = n; updateNode(); }), function() /*=>*/ {return sides}     ],
		[ "Thickness", textBox_Number(function(n) /*=>*/ { thickness = n; updateNode(); }), function() /*=>*/ {return thickness} ],
		[ "Gap",       textBox_Number(function(n) /*=>*/ { gap       = n; updateNode(); }), function() /*=>*/ {return gap}       ],
	];
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color(_col);
		draw_set_alpha(_alp);
		
		var _sd = params[$ "sides"]     ?? sides;     params[$ "sides"]     = sides;
		var _th = params[$ "thickness"] ?? thickness; params[$ "thickness"] = thickness;
		var _gp = params[$ "gap"]       ?? gap;       params[$ "gap"]       = gap;
		
		var _ss = min(_sx, _sy) / 2;
		if(_ss < 1) { draw_point(_x, _y); draw_set_alpha(1); return; }
		
		var _gap = _gp + 1;
		var _sp  = _ss / (_th * _gap) * _sd;
		
		var _a  = _ang;
		var _l  = 0;
		
		var _as = 360 / _sd;
		var _ls = _th * _gap / _sd;
		
		var _ox = _x;
		var _oy = _y;
		var _nx, _ny;
		
		repeat(_sp) {
			_a += _as;
			_l += _ls;
			
			_nx = _x + lengthdir_x(_l, _a);
			_ny = _y + lengthdir_y(_l, _a);
			
			draw_line_round(_ox, _oy, _nx, _ny, _th);
			
			_ox = _nx;
			_oy = _ny;
		}
		
		_a += _as * frac(_sp);
		_l += _ls * frac(_sp);
		
		_nx = _x + lengthdir_x(_l, _a);
		_ny = _y + lengthdir_y(_l, _a);
		
		draw_line_round(_ox, _oy, _nx, _ny, _th);
		
		draw_set_alpha(1);
	}
	
	static doSerialize = function(m) {
		m.sides     = sides;
		m.thickness = thickness;
		m.gap       = gap;
	}
	
	static deserialize = function(m) { 
		sides     = m[$ "sides"] ?? sides;
		thickness = m[$ "thickness"] ?? thickness;
		gap       = m[$ "gap"] ?? gap;
		
		return self; 
	}
	
	static clone = function() /*=>*/ {
		var n = variable_clone(self);
		
		n.sides      = 8;
		n.thickness  = 1;
		n.gap        = 2;
		
		return n;
	}
}