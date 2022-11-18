function Node_create_Iterator_Index(_x, _y) {
	var node = new Node_Iterator_Index(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Iterator_Index(_x, _y) : Node(_x, _y) constructor {
	name = "Index";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 1;
	
	outputs[| 0] = nodeValue(0, "Loop index", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0);
	
	static update = function() { 
		if(variable_struct_exists(group, "iterated"))
			outputs[| 0].setValue(group.iterated);
	}
}