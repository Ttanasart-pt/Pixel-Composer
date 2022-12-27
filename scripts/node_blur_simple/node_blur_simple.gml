function Node_Blur_Simple(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Simple blur";
	
	shader = sh_blur_simple;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_siz = shader_get_uniform(shader, "size");
	uniform_sam = shader_get_uniform(shader, "sampleMode");
	
	uniform_umk = shader_get_uniform(shader, "useMask");
	uniform_msk = shader_get_sampler_index(shader, "mask");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[| 2] = nodeValue(2, "Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
	
	inputs[| 3] = nodeValue(3, "Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	input_display_list = [ 
		["Surface",	false],	0, 3, 2, 
		["Effect",  false],	1, 
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index) {
		if(!is_surface(_data[0])) return _outSurf;
		var _size	= _data[1];
		var _samp	= _data[2];
		var _mask	= _data[3];
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_OVER
			
			shader_set(shader);
			shader_set_uniform_f(uniform_dim, surface_get_width(_data[0]), surface_get_height(_data[0]));
			shader_set_uniform_f(uniform_siz, _size);
			shader_set_uniform_i(uniform_sam, _samp);
			
			shader_set_uniform_i(uniform_umk, is_surface(_mask));
			if(is_surface(_mask)) 
				texture_set_stage(uniform_msk, surface_get_texture(_mask));
			
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}