function dynaDraw_polygon_fill_gradient() : dynaDraw() constructor {
	
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
		
		var _aa = 360 / sides;
		
		draw_primitive_begin(pr_trianglelist);
			for( var i = 0; i < sides; i++ ) {
				var a0 = _ang + i * _aa;
				var a1 = a0 + _aa;
				
				draw_vertex_color(_x, _y, _col, _alp);
				draw_vertex_color(_x + lengthdir_x(_sx / 2, a0), _y + lengthdir_y(_sy / 2, a0), c_black, _alp);
				draw_vertex_color(_x + lengthdir_x(_sx / 2, a1), _y + lengthdir_y(_sy / 2, a1), c_black, _alp);
			}
		draw_primitive_end();
	
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