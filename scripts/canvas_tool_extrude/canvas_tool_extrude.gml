function canvas_tool_extrude() : canvas_tool_shader() constructor {
	
	mouse_sx   = 0;
	mouse_sy   = 0;
	
	static init = function() { mouse_init = true; }
	
	static onInit = function(hover, active, _x, _y, _s, _mx, _my) {
		mouse_sx   = _mx;
		mouse_sy   = _my;
	}
	
	static stepEffect = function(hover, active, _x, _y, _s, _mx, _my) {
		var _dim  = node.attributes.dimension;
		
		var _dx = (_mx - mouse_sx) / _s;
		var _dy = (_my - mouse_sy) / _s;
		
		if(key_mod_press(CTRL)) {
			var ang  = point_direction(0, 0, _dx, _dy);
			var dist = point_distance(0, 0, _dx, _dy);
			ang = round(ang / 45) * 45;
			
			_dx = lengthdir_x(dist, ang);
			_dy = lengthdir_y(dist, ang);
		}
		
		surface_set_shader(preview_surface[1], sh_canvas_extrude);
			
			shader_set_f("dimension", _dim);
			shader_set_f("shift",     _dx, _dy);
			shader_set_f("itr",       round(sqrt(_dx * _dx + _dy * _dy)));
			shader_set_color("color", CURRENT_COLOR);
			
			draw_surface_safe(preview_surface[0]);
		surface_reset_shader();
		
	}
}