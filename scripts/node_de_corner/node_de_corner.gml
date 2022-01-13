function Node_create_De_Corner(_x, _y) {
	var node = new Node_De_Corner(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_De_Corner(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "De-Corner";
	
	uniform_dim = shader_get_uniform(sh_de_corner, "dimension");
	uniform_sol = shader_get_uniform(sh_de_corner, "solid");
	uniform_tol = shader_get_uniform(sh_de_corner, "tolerance");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	function process_data(_outSurf, _data, _output_index) {
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
		
		shader_set(sh_de_corner);
			shader_set_uniform_f_array(uniform_dim, [ surface_get_width(_data[0]), surface_get_height(_data[0]) ]);
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}