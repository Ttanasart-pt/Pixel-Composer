function Node_Bloom(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Bloom";
	
	shader = sh_bloom_pass;
	uniform_size = shader_get_uniform(shader, "size");
	uniform_tole = shader_get_uniform(shader, "tolerance");
	
	uniform_umsk = shader_get_uniform(shader, "useMask");
	uniform_mask = shader_get_sampler_index(shader, "mask");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3, "Bloom blur radius.")
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[| 2] = nodeValue(2, "Tolerance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5, "How bright a pixel should be to start blooming.")
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	inputs[| 3] = nodeValue(3, "Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, .25, "Blend intensity.")
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 2, 0.01]);
		
	inputs[| 4] = nodeValue(4, "Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	input_display_list = [
		["Surface", true],	0, 4,
		["Bloom",	false],	1, 2, 3,
	]
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _size = _data[1];
		var _tole = _data[2];
		var _stre = _data[3];
		var _mask = _data[4];
		var pass1 = surface_create_valid(surface_get_width(_outSurf), surface_get_height(_outSurf));	
		
		surface_set_target(pass1);
		draw_clear_alpha(c_black, 1);
			shader_set(shader);
				shader_set_uniform_f(uniform_size, _size);
				shader_set_uniform_f(uniform_tole, _tole);
				
				shader_set_uniform_i(uniform_umsk, is_surface(_mask));
				texture_set_stage(uniform_mask, surface_get_texture(_mask));
				
				draw_surface_safe(_data[0], 0, 0);
			shader_reset();
		surface_reset_target();
		
		pass1 = surface_apply_gaussian(pass1, _size, true, c_black, 1);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE
		
			var uniform_foreground = shader_get_sampler_index(sh_blend_add_alpha_adj, "fore");
			var uniform_opacity    = shader_get_uniform(sh_blend_add_alpha_adj, "opacity");
			
			shader_set(sh_blend_add_alpha_adj);
			texture_set_stage(uniform_foreground,	surface_get_texture(pass1));
			shader_set_uniform_f(uniform_opacity,	_stre);
			
			draw_surface_safe(_data[0], 0, 0);
			
			shader_reset();
			
			BLEND_NORMAL
		surface_reset_target();
		
		surface_free(pass1);
		
		return _outSurf;
	}
}