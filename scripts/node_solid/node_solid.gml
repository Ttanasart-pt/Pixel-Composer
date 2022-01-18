function Node_create_Solid(_x, _y) {
	var node = new Node_Solid(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Solid(_x, _y) : Node(_x, _y) constructor {
	name = "Solid";
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	static update = function() {
		var _dim   = inputs[| 0].getValue();
		var _col   = inputs[| 1].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf = surface_create(surface_valid(_dim[0]), surface_valid(_dim[1]));
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, surface_valid(_dim[0]), surface_valid(_dim[1]));
		
		surface_set_target(_outSurf);
			draw_clear(_col);
		surface_reset_target();
	}
	doUpdate();
}