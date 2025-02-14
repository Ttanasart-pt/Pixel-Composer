function dynaDraw_square_outline() : dynaDraw() constructor {
	
	thickness = 1;
	editors   = [
		[ "Thickness", new textBox(TEXTBOX_INPUT.number, function(n) /*=>*/ { thickness = n; updateNode(); }), function() /*=>*/ {return thickness} ]
	];
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color(_col);
		draw_set_alpha(_alp);
		
		if(round(_sx) <= 1 && round(_sy) <= 0) {
			draw_point(_x, _y);
			draw_set_alpha(1);
			return;
		}
		
		if(thickness <= 1) draw_rectangle(_x - _sx / 2, _y - _sy / 2, _x + _sx / 2, _y + _sy / 2, true);
		else        draw_rectangle_border(_x - _sx / 2, _y - _sy / 2, _x + _sx / 2, _y + _sy / 2, thickness);
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