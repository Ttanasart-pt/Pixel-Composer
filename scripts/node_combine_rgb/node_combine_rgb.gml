function Node_Combine_RGB(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "RGB Combine";
	
	shader = sh_combine_rgb;
	uniform_r = shader_get_sampler_index(shader, "samR");
	uniform_g = shader_get_sampler_index(shader, "samG");
	uniform_b = shader_get_sampler_index(shader, "samB");
	
	inputs[| 0] = nodeValue(0, "Red",   self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Green", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 2] = nodeValue(2, "Blue",  self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _r = _data[0];
		var _g = _data[1];
		var _b = _data[2];
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVER
		
		shader_set(shader);
			texture_set_stage(uniform_r, surface_get_texture(_r));
			texture_set_stage(uniform_g, surface_get_texture(_g));
			texture_set_stage(uniform_b, surface_get_texture(_b));
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, surface_get_width(_outSurf), surface_get_width(_outSurf), 0, c_white, 1);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}