function Node_Combine_HSV(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "HSV Combine";
	
	shader = sh_combine_hsv;
	uniform_h = shader_get_sampler_index(shader, "samH");
	uniform_s = shader_get_sampler_index(shader, "samS");
	uniform_v = shader_get_sampler_index(shader, "samV");
	
	inputs[| 0] = nodeValue("Hue",        self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue("Saturation", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 2] = nodeValue("Value",      self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _h = _data[0];
		var _s = _data[1];
		var _v = _data[2];
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		shader_set(shader);
			texture_set_stage(uniform_h, surface_get_texture(_h));
			texture_set_stage(uniform_s, surface_get_texture(_s));
			texture_set_stage(uniform_v, surface_get_texture(_v));
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, surface_get_width_safe(_outSurf), surface_get_width_safe(_outSurf), 0, c_white, 1);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}