function dynaDraw_polygon_fill() : dynaDraw() constructor {
	
	sides   = 6;
	editors = [
		[ "Sides", new textBox(TEXTBOX_INPUT.number, function(n) /*=>*/ { sides = max(3, round(n)); updateNode(); }), function() /*=>*/ {return sides} ],
	];
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color(_col);
		draw_set_alpha(_alp);
		
		if(round(_sx) <= 1 && round(_sy) <= 0) {
			draw_point(_x, _y);
			draw_set_alpha(1);
			return;
		}
		
		draw_polygon_rect(_x, _y, _sx / 2, _sy / 2, sides, _ang);
		draw_set_alpha(1);
	}
	
	static doSerialize = function(m) {
		m.sides = sides;
	}
	
	static deserialize = function(m) { 
		sides = m[$ "sides"] ?? 6;
		
		return self; 
	}
}