function Node_create_Padding(_x, _y) {
	var node = new Node_Padding(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Padding(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Padding";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0, 0, 0])
		.setDisplay(VALUE_DISPLAY.padding);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	static process_data = function(_outSurf, _data, _output_index) {
		var padding	= _data[1];
		
		var ww	= surface_get_width(_data[0]);
		var hh	= surface_get_height(_data[0]);
		
		var sw	= ww + padding[0] + padding[2];
		var sh	= hh + padding[1] + padding[3];
		
		if(sw > 1 && sh > 1) { 
			surface_size_to(_outSurf, sw, sh);
			
			surface_set_target(_outSurf);
				draw_clear_alpha(0, 0);
				BLEND_ADD
				draw_surface_safe(_data[0], padding[2], padding[1]);
				BLEND_NORMAL
			surface_reset_target();
		}
		return _outSurf;
	}
}