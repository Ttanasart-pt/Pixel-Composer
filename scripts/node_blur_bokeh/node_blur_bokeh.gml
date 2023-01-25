function Node_Blur_Bokeh(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Lens Blur";
	
	shader = sh_blur_bokeh;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_str = shader_get_uniform(shader, "strength");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider, [0, 16, 0.01]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _str = _data[1];
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE
			
			shader_set(shader);
			shader_set_uniform_f(uniform_dim, surface_get_width(_data[0]), surface_get_height(_data[0]));
			shader_set_uniform_f(uniform_str, _str);
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}