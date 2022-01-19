function Node_create_Scale(_x, _y) {
	var node = new Node_Scale(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Scale(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Scale";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 2] = nodeValue(2, "Keep dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	static process_data = function(_outSurf, _data, _output_index) {
		var scale	= _data[1];
		var keep	= _data[2];
		
		var ww	= surface_get_width(_data[0]);
		var hh	= surface_get_height(_data[0]);
		
		var sw	= keep? ww : ww * scale;
		var sh	= keep? hh : hh * scale;
		
		if(sw > 1 && sh > 1) { 
			surface_size_to(_outSurf, sw, sh);
			
			surface_set_target(_outSurf);
				var cx = keep? (ww - ww * scale) / 2 : 0;
				var cy = keep? (ww - hh * scale) / 2 : 0;
				
				draw_clear_alpha(0, 0);
				BLEND_ADD
				draw_surface_ext_safe(_data[0], cx, cy, scale, scale, 0, c_white, 1);		
				BLEND_NORMAL
			surface_reset_target();
		}
		return _outSurf;
	}
}