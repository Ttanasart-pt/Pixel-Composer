function Node_create_Erode(_x, _y) {
	var node = new Node_Erode(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Erode(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Erode";
	
	uniform_dim   = shader_get_uniform(sh_erode, "dimension");
	uniform_size  = shader_get_uniform(sh_erode, "size");
	uniform_bor   = shader_get_uniform(sh_erode, "border");
	
	inputs[| 0] = nodeValue(0, "Surface in",	 self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Width",			 self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1);
	inputs[| 2] = nodeValue(2, "Preserve border",self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	function process_data(_outSurf, _data, _output_index) {
		var wd = _data[1];
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
		
		shader_set(sh_erode);
			shader_set_uniform_f_array(uniform_dim, [surface_get_width(_data[0]), surface_get_height(_data[0])]);
			shader_set_uniform_f(uniform_size, wd);
			shader_set_uniform_i(uniform_bor, _data[2]? 1 : 0);
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}