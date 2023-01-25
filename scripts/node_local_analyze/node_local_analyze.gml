function Node_Local_Analyze(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Local Analyze";
	
	shader = sh_local_analyze;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_alg = shader_get_uniform(shader, "algorithm");
	uniform_siz = shader_get_uniform(shader, "size");
	uniform_sha = shader_get_uniform(shader, "shape");
	uniform_sam = shader_get_uniform(shader, "sampleMode");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Algorithm", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Average (Blur)", "Maximum", "Minimum" ]);
	
	inputs[| 2] = nodeValue(2, "Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 1, 16, 1]);
	
	inputs[| 3] = nodeValue(3, "Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
	
	inputs[| 4] = nodeValue(4, "Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Square", "Circle", "Diamond" ]);
		
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [
		["Surface",	false],	0, 3,
		["Effect",	false],	1, 2, 4,
	];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _alg = _data[1];
		var _siz = _data[2];
		var _sam = _data[3];
		var _shp = _data[4];
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVERRIDE
		
		shader_set(shader);
			shader_set_uniform_f(uniform_dim, surface_get_width(_data[0]), surface_get_height(_data[0]));
			shader_set_uniform_i(uniform_alg, _alg);
			shader_set_uniform_i(uniform_sam, _sam);
			shader_set_uniform_i(uniform_sha, _shp);
			shader_set_uniform_f(uniform_siz, _siz);
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}