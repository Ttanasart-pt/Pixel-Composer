function Node_create_RGB_Channel(_x, _y) {
	var node = new Node_RGB_Channel(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_RGB_Channel(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "RGB Channel";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue(0, "Surface red", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	outputs[| 1] = nodeValue(1, "Surface green", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	outputs[| 2] = nodeValue(2, "Surface ble", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	function process_data(_outSurf, _data, output_index) {
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
			switch(output_index) {
				case 0 : shader_set(sh_channel_R); break;
				case 1 : shader_set(sh_channel_G); break;
				case 2 : shader_set(sh_channel_B); break;
			}
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}