function Node_create_Texture_Remap(_x, _y) {
	var node = new Node_Texture_Remap(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Texture_Remap(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Texture remap";
	
	uniform_map = shader_get_sampler_index(sh_texture_remap, "map");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "RG Map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index) {
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
		
		if(_data[1]) {
			shader_set(sh_texture_remap);
				texture_set_stage(uniform_map, surface_get_texture(_data[1]));
				draw_surface_safe(_data[0], 0, 0);
			shader_reset();
		}
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}