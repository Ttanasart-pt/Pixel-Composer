function Node_Corner(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Round corner";
	
	uniform_er_dim   = shader_get_uniform(sh_corner_erode, "dimension");
	uniform_er_size  = shader_get_uniform(sh_corner_erode, "size");
	
	uniform_dim  = shader_get_uniform(sh_corner, "dimension");
	uniform_rad  = shader_get_uniform(sh_corner, "rad");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2)
		.setDisplay(VALUE_DISPLAY.slider, [2, 16, 1]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var wd = _data[1];
		
		var temp = surface_create_valid(surface_get_width(_data[0]), surface_get_height(_data[0]));
		
		surface_set_target(temp);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE
			
			shader_set(sh_corner_erode);
			shader_set_uniform_f_array(uniform_er_dim, [surface_get_width(_data[0]), surface_get_height(_data[0])]);
			shader_set_uniform_f(uniform_er_size, wd);
			draw_surface_safe(_data[0], 0, 0);
			
			BLEND_NORMAL
			shader_reset();
		surface_reset_target();
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE
			
			shader_set(sh_corner);
			shader_set_uniform_f_array(uniform_dim, [surface_get_width(_data[0]), surface_get_height(_data[0])]);
			shader_set_uniform_f(uniform_rad, wd);
			draw_surface_safe(temp, 0, 0);
			
			BLEND_NORMAL
		shader_reset();
		surface_reset_target();
		
		surface_free(temp);
		return _outSurf;
	}
}