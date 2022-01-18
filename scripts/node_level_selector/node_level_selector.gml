function Node_create_Level_Selector(_x, _y) {
	var node = new Node_Level_Selector(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Level_Selector(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Level Selector";
	
	uniform_middle = shader_get_uniform(sh_level_selector, "middle");
	uniform_range  = shader_get_uniform(sh_level_selector, "range");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Middle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	inputs[| 2] = nodeValue(2, "Range",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _middle = _data[1];
		var _range  = _data[2];
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
			
			shader_set(sh_level_selector);
			shader_set_uniform_f(uniform_middle, _middle);
			shader_set_uniform_f(uniform_range , _range );
			
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}