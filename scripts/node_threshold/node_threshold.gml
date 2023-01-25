function Node_Threshold(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Threshold";
	
	shader = sh_threshold;
	uniform_mde = shader_get_uniform(shader, "mode");
	uniform_thr = shader_get_uniform(shader, "thr");
	uniform_smt = shader_get_uniform(shader, "smooth");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Mode",   self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Brightness", "Alpha" ]);
		
	inputs[| 2] = nodeValue(2, "Threshold",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
		
	inputs[| 3] = nodeValue(3, "Smoothness",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [ 0,
		["Threshold",	false], 1, 2, 3
	];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _mode = _data[1];
		var _thr  = _data[2];
		var _smt  = _data[3];
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVERRIDE
		
		shader_set(shader);
			shader_set_uniform_i(uniform_mde,  _mode);
			shader_set_uniform_f(uniform_thr, _thr);
			shader_set_uniform_f(uniform_smt, _smt);
			
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}
