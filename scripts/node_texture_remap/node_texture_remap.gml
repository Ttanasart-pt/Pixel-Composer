function Node_Texture_Remap(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Texture Remap";
	
	shader = sh_texture_remap;
	uniform_map = shader_get_sampler_index(shader, "map");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("RG Map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0, "Displacement map where red retermine the X position, and green determine the Y position.");
	
	inputs[| 2] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 2;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 2,
		["Output",	 false], 0, 1, 
	]
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		if(!is_surface(_data[1])) return _outSurf;
		
		surface_set_shader(_outSurf, shader);
		shader_set_interpolation(_data[0]);
			texture_set_stage(uniform_map, surface_get_texture(_data[1]));
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}