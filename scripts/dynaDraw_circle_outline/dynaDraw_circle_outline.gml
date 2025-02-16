function dynaDraw_circle_outline() : dynaDraw() constructor {
	
	parameters = [ "thickness" ];
	thickness  = 1;
	editors    = [
		[ "Thickness", new textBox(TEXTBOX_INPUT.number, function(n) /*=>*/ { thickness = n; updateNode(); }), function() /*=>*/ {return thickness} ],
	];
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color(_col);
		draw_set_alpha(_alp);
		draw_set_circle_precision(32);
		
		var _th = params[$ "thickness"] ?? thickness; params[$ "thickness"] = thickness;
		
		if(_sx != _sy) {
			if(_th <= 1) draw_ellipse(_x - _sx / 2, _y - _sy / 2, _x + _sx / 2, _y + _sy / 2, true);
			else         draw_ellipse_border(_x - _sx / 2, _y - _sy / 2, _x + _sx / 2, _y + _sy / 2, _th);
			draw_set_alpha(1);
			return;
		}
		
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
				draw_point( _x - 1, _y     );
				draw_point( _x + 1, _y     );
				draw_point( _x,     _y + 1 );
				draw_point( _x,     _y - 1 );
				if(_th > 1) draw_point( _x, _y );
				break;
				
			default : 
				if(_th <= 1) draw_circle(_x - 1, _y - 1, _sx / 2 - 1, true);
				else         draw_circle_border(_x, _y, _sx / 2 - 1, _th);
				break;
		}
		
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
