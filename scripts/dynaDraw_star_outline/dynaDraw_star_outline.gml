function dynaDraw_star_outline() : dynaDraw() constructor {
	
	parameters = [ "sides", "inner", "thickness" ];
	sides      = 6;
	inner      = .5;
	thickness  = 1;
	editors    = [
		[ "Sides", new textBox(TEXTBOX_INPUT.number, function(n) /*=>*/ { sides = max(3, round(n)); updateNode(); }), function() /*=>*/ {return sides} ],
		[ "Inner", new textBox(TEXTBOX_INPUT.number, function(n) /*=>*/ { inner = n; updateNode(); }), function() /*=>*/ {return inner} ],
		[ "Thickness", new textBox(TEXTBOX_INPUT.number, function(n) /*=>*/ { thickness = n; updateNode(); }), function() /*=>*/ {return thickness} ],
	];
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color(_col);
		draw_set_alpha(_alp);
		
		if(round(_sx) <= 1 && round(_sy) <= 0) {
			draw_point(_x, _y);
			draw_set_alpha(1);
			return;
		}
		
		var _th = params[$ "thickness"] ?? thickness; params[$ "thickness"] = thickness;
		var _sd = params[$ "sides"] ?? sides; params[$ "sides"] = sides; 
		var _in = params[$ "inner"] ?? inner; params[$ "inner"] = inner; 
		    _sd = max(3, round(_sd));
		
		var aa = 360 / _sd;
		var sw = _sx/2, swi = sw*_in;
		var sh = _sy/2, shi = sh*_in;
		
		for( var i = 0; i < _sd; i++ ) {
			var a0 = _ang + i * aa;
			var a1 = a0 + aa / 2;
			var a2 = a1 + aa / 2;
			
			draw_line_round(_x + lengthdir_x(sw, a0), _y + lengthdir_y(sh, a0), _x + lengthdir_x(swi, a1), _y + lengthdir_y(shi, a1), _th);
			draw_line_round(_x + lengthdir_x(sw, a2), _y + lengthdir_y(sh, a2), _x + lengthdir_x(swi, a1), _y + lengthdir_y(shi, a1), _th);
		}
		
		draw_set_alpha(1);
	}
	
	static doSerialize = function(m) {
		m.sides = sides;
		m.inner = inner;
		m.thickness = thickness;
	}
	
	static deserialize = function(m) { 
		sides = m[$ "sides"] ?? sides;
		inner = m[$ "inner"] ?? inner;
		thickness = m[$ "thickness"] ?? thickness;
		
		return self; 
	}
}