function dynaDraw_cross() : dynaDraw() constructor {
	
	parameters = [ "thickness" ];
	thickness  = 1;
	cap        = false;
	editors    = [
		[ "Thickness", new textBox(TEXTBOX_INPUT.number, function(n) /*=>*/ { thickness = n; updateNode(); }), function() /*=>*/ {return thickness} ],
		[ "Round Cap", new checkBox(function() /*=>*/ { cap = !cap; updateNode(); }), function() /*=>*/ {return cap} ],
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
		
		var _lw = lengthdir_x(_sx / 2, _ang),    _lh = lengthdir_y(_sy / 2, _ang);
		var _cw = lengthdir_x(_sx / 2, _ang+90), _ch = lengthdir_y(_sy / 2, _ang+90);
		
		if(cap) {
			draw_line_round(_x-_lw, _y-_lh, _x+_lw, _y+_lh, _th);
			draw_line_round(_x-_cw, _y-_ch, _x+_cw, _y+_ch, _th);
			
		} else {
			draw_line_width(_x-_lw, _y-_lh, _x+_lw, _y+_lh, _th);
			draw_line_width(_x-_cw, _y-_ch, _x+_cw, _y+_ch, _th);
		}
		
		draw_set_alpha(1);
	}
	
	static doSerialize = function(m) {
		m.thickness = thickness;
		m.cap = cap;
	}
	
	static deserialize = function(m) { 
		thickness = m[$ "thickness"] ?? 1;
		cap = m[$ "cap"] ?? false;
		
		return self; 
	}
}