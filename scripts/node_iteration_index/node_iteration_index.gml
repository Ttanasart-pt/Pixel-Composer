function Node_Iterator_Index(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
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