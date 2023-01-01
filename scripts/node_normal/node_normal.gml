function Node_Normal(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Normal";
	
	uniform_dim = shader_get_uniform(sh_normal, "dimension");
	uniform_hei = shader_get_uniform(sh_normal, "height");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _hei = _data[1];
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVER
		
		shader_set(sh_normal);
			shader_set_uniform_f(uniform_hei, _hei);
			shader_set_uniform_f_array(uniform_dim, [ surface_get_width(_data[0]), surface_get_height(_data[0]) ]);
			
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}