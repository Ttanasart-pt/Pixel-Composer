function dynaDraw_square_outline() : dynaDraw() constructor {
	
	parameters = [ "thickness" ];
	thickness  = 1;
	editors    = [
		[ "Thickness", new textBox(TEXTBOX_INPUT.number, function(n) /*=>*/ { thickness = n; updateNode(); }), function() /*=>*/ {return thickness} ]
	];
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color(_col);
		draw_set_alpha(_alp);
		
		var _th = params[$ "thickness"] ?? thickness; params[$ "thickness"] = thickness;
		
		if(round(_sx) <= 1 && round(_sy) <= 0) {
			draw_point(_x, _y);
			draw_set_alpha(1);
			return;
		}
		
		var x0 = _x - _sx / 2;
		var y0 = _y - _sy / 2;
		var x1 = _x + _sx / 2;
		var y1 = _y + _sy / 2;
		
		if(_th <= 1) draw_rectangle(       x0+1, y0+1, x1+1, y1+1, true);
		else         draw_rectangle_border(x0,   y0,   x1,   y1,   _th);
		draw_set_alpha(1);
	}
	
	static doSerialize = function(m) {
		m.thickness = thickness;
	}
	
	static deserialize = function(m) { 
		thickness = m[$ "thickness"] ?? 1;
		
		return self; 
	}
}