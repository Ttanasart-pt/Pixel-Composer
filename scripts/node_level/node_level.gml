function Node_create_Level(_x, _y) {
	var node = new Node_Level(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Level(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Level";
	
	uniform_black = shader_get_uniform(sh_level, "black");
	uniform_white = shader_get_uniform(sh_level, "white");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Black", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	inputs[| 2] = nodeValue(2, "White",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	function process_data(_outSurf, _data, _output_index) {
		var _black = _data[1];
		var _white = _data[2];
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
		
		shader_set(sh_level);
			shader_set_uniform_f(uniform_black, _black);
			shader_set_uniform_f(uniform_white, _white);
			
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}