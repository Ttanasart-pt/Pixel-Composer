function dynaDraw_leaf_fill() : dynaDraw() constructor {
	
	parameters = [ "width" ];
	width      = .5;
	editors    = [
		[ "Width", textBox_Number(function(n) /*=>*/ { width = n; updateNode(); }), function() /*=>*/ {return width} ],
	];
	
	static draw = function(_x = 0, _y = 0, _sx = 1, _sy = 1, _ang = 0, _col = c_white, _alp = 1) {
		draw_set_color(_col);
		draw_set_alpha(_alp);
		
		if(round(_sx) <= 1 && round(_sy) <= 0) {
			draw_point(_x, _y);
			draw_set_alpha(1);
			return;
		}
		
		var _wd = params[$ "width"] ?? width; params[$ "width"] = width;
		
		var _lw = _sx / 2;
		var _lh = _sy / 2 * _wd;
		 
		draw_primitive_begin(pr_trianglestrip);
			draw_vertex(_x + lengthdir_x(_lw, _ang),      _y + lengthdir_y(_lw, _ang));
			draw_vertex(_x + lengthdir_x(_lh, _ang + 90), _y + lengthdir_y(_lh, _ang + 90));
			draw_vertex(_x + lengthdir_x(_lh, _ang - 90), _y + lengthdir_y(_lh, _ang - 90));
			draw_vertex(_x + lengthdir_x(_lw, _ang + 180),_y + lengthdir_y(_lw, _ang + 180));
		draw_primitive_end();
		
		draw_set_alpha(1);
	}
	
	static doSerialize = function(m) {
		m.width = width;
	}
	
	static deserialize = function(m) { 
		width = m[$ "width"] ?? .5;
		return self; 
	}
}