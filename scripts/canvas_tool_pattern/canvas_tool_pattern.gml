function canvas_tool_pattern(toolAttr) : canvas_tool_shader() constructor {
	tool_attribute = toolAttr;
	
	seed     = seed_random();
	mouse_sx = 0;
	mouse_sy = 0;
	
	prev_surface = surface_create(8, 8);
			   
	static init = function() { mouse_init = true; }
	
	static onInit = function(hover, active, _x, _y, _s, _mx, _my) {
		mouse_sx = _mx;
		mouse_sy = _my;
	}
	
	static stepEffect = function(hover, active, _x, _y, _s, _mx, _my) {
		var _dim = node.attributes.dimension;
		
		var px = round((mouse_sx - _x) / _s);
		var py = round((mouse_sy - _y) / _s);
		
		surface_set_shader(preview_surface[1], sh_canvas_pattern);
			
			shader_set_i("empty",    0);
			shader_set_f("seed",     seed);
			shader_set_f("dimension", _dim);
			shader_set_color("color", CURRENT_COLOR);
			
			shader_set_i("pattern",       tool_attribute.pattern);
			shader_set_f("pattern_inten", tool_attribute.pattern_inten);
			shader_set_2("pattern_scale", tool_attribute.pattern_scale);
			shader_set_2("pattern_pos",   [ px, py ]);
			shader_set_f("pattern_mod",   tool_attribute.pattern_mod);
			
			draw_surface_safe(preview_surface[0]);
		surface_reset_shader();
		
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my ) {
		var _dim = node.attributes.dimension;
		
		var px = round((_mx - _x) / _s);
		var py = round((_my - _y) / _s);
		
		prev_surface = surface_verify(prev_surface, _dim[0], _dim[1]);
		
		surface_set_shader(prev_surface, sh_canvas_pattern);
			shader_set_i("empty",     1);
			shader_set_f("seed",      seed);
			shader_set_f("dimension", _dim);
			shader_set_color("color", CURRENT_COLOR);
			
			shader_set_i("pattern",       tool_attribute.pattern);
			shader_set_f("pattern_inten", tool_attribute.pattern_inten);
			shader_set_2("pattern_scale", tool_attribute.pattern_scale);
			shader_set_2("pattern_pos",   [ px, py ]);
			shader_set_f("pattern_mod",   tool_attribute.pattern_mod);
			
			draw_empty();
		surface_reset_shader();
		
		draw_surface_ext(prev_surface, _x, _y, _s, _s, 0, c_white, .25);
	}
}