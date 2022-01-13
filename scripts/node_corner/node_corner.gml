function Node_create_Corner(_x, _y) {
	var node = new Node_Corner(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Corner(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Round corner";
	
	uniform_er_dim   = shader_get_uniform(sh_erode, "dimension");
	uniform_er_size  = shader_get_uniform(sh_erode, "size");
	uniform_er_bor   = shader_get_uniform(sh_erode, "border");
	
	uniform_dim          = shader_get_uniform(sh_outline, "dimension");
	uniform_border_size  = shader_get_uniform(sh_outline, "borderSize");
	uniform_border_color = shader_get_uniform(sh_outline, "borderColor");
	
	uniform_blend		= shader_get_uniform(sh_outline, "is_blend");
	uniform_blend_alpha = shader_get_uniform(sh_outline, "blend_alpha");
	
	uniform_side		= shader_get_uniform(sh_outline, "side");
	uniform_aa  		= shader_get_uniform(sh_outline, "is_aa");
	
	uniform_out_only	= shader_get_uniform(sh_outline, "outline_only");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2)
		.setDisplay(VALUE_DISPLAY.slider, [1, 16, 1]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	function process_data(_outSurf, _data, _output_index) {
		var wd = _data[1];
		
		var temp = surface_create(surface_get_width(_data[0]), surface_get_height(_data[0]));
		
		surface_set_target(temp);
			draw_clear_alpha(0, 0);
			BLEND_ADD
			
			shader_set(sh_erode);
			shader_set_uniform_f_array(uniform_er_dim, [surface_get_width(_data[0]), surface_get_height(_data[0])]);
			shader_set_uniform_f(uniform_er_size, wd);
			shader_set_uniform_i(uniform_er_bor, 1);
			draw_surface_safe(_data[0], 0, 0);
			
			BLEND_NORMAL
			shader_reset();
		surface_reset_target();
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
			
			shader_set(sh_outline);
			shader_set_uniform_f_array(uniform_dim, [surface_get_width(_data[0]), surface_get_height(_data[0])]);
			shader_set_uniform_f(uniform_border_size, wd);
			shader_set_uniform_f_array(uniform_border_color, [0, 0, 0 ]);
			
			shader_set_uniform_i(uniform_side, 1);
			shader_set_uniform_i(uniform_aa, 0);
			shader_set_uniform_i(uniform_out_only, 0);
			shader_set_uniform_i(uniform_blend, 1);
			shader_set_uniform_f(uniform_blend_alpha, 0);
			draw_surface_safe(temp, 0, 0);
			
			BLEND_NORMAL
		shader_reset();
		surface_reset_target();
		
		surface_free(temp);
		return _outSurf;
	}
}