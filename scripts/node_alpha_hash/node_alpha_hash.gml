function Node_Alpha_Hash(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Alpha hash";
	
	shader = sh_alpha_hash;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_dit = shader_get_uniform(shader, "dither");
	
	static dither8 =  [    0, 32,  8, 40,  2, 34, 10, 42, 
						  48, 16, 56, 24, 50, 18, 58, 26,
						  12, 44,  4, 36, 14, 46,  6, 38, 
						  60, 28, 52, 20, 62, 30, 54, 22,
						   3, 35, 11, 43,  1, 33,  9, 41,
						  51, 19, 59, 27, 49, 17, 57, 25,
						  15, 47,  7, 39, 13, 45,  5, 37,
						  63, 31, 55, 23, 61, 29, 53, 21];
						  
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		shader_set(shader);
			shader_set_uniform_f(uniform_dim, surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_uniform_f_array_safe(uniform_dit, dither8);
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	} #endregion
}