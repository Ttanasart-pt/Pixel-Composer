function Node_Texture_Remap(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Texture Remap";
	
	shader = sh_texture_remap;
	uniform_map = shader_get_sampler_index(shader, "map");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("RG Map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0, "Displacement map where red retermine the X position, and green determine the Y position.");
	
	inputs[| 2] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 2;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 2,
		["Surface",	 false], 0, 1, 
	]
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		if(!is_surface(_data[1])) return _outSurf;
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVERRIDE;
		
		shader_set(shader);
			texture_set_stage(uniform_map, surface_get_texture(_data[1]));
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}