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
		
		if(round(_sx) <= 1 && round(_sy) <= 1) {
			draw_point(_x, _y);
			draw_set_alpha(1);
			return;
		}
		
		_x = round(_x);
		_y = round(_y);
		
		if(_ang == 0) {
			var sx = round(_sx/2);
			var sy = round(_sy/2);
			
			if(_th == 1) {
				draw_line(_x-sx, _y, _x+sx-1, _y);
				draw_line(_x, _y-sy, _x, _y+sy-1);
				
			} else if(cap) {
				draw_line_round(_x-sx, _y, _x+sx, _y, _th);
				draw_line_round(_x, _y-sy, _x, _y+sy, _th);
				
			} else {
				draw_line_width(_x-sx, _y, _x+sx, _y, _th);
				draw_line_width(_x, _y-sy, _x, _y+sy, _th);
			}
			
		} else {
			var _lw = lengthdir_x(ceil(_sx/2), _ang),    _lh = lengthdir_y(ceil(_sy/2), _ang);
			var _cw = lengthdir_x(ceil(_sx/2), _ang+90), _ch = lengthdir_y(ceil(_sy/2), _ang+90);
			
			if(_th == 1) {
				draw_line(_x-_lw, _y-_lh, _x+_lw, _y+_lh);
				draw_line(_x-_cw, _y-_ch, _x+_cw, _y+_ch);
				
			} else if(cap) {
				draw_line_round(_x-_lw, _y-_lh, _x+_lw, _y+_lh, _th);
				draw_line_round(_x-_cw, _y-_ch, _x+_cw, _y+_ch, _th);
				
			} else {
				draw_line_width(_x-_lw, _y-_lh, _x+_lw, _y+_lh, _th);
				draw_line_width(_x-_cw, _y-_ch, _x+_cw, _y+_ch, _th);
			}
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