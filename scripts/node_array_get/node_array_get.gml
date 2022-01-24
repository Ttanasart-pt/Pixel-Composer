function Node_create_Array_Get(_x, _y) {
	var node = new Node_Array_Get(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Array_Get(_x, _y) : Node(_x, _y) constructor {
	name		= "Array Get";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue(0, "Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue(1, "Index", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	outputs[| 0] = nodeValue(0, "Size", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	static update = function() {
		var _arr = inputs[| 0].getValue();
		if(!is_array(_arr)) return;
		var index = clamp(inputs[| 1].getValue(), 0, array_length(_arr) - 1);
		outputs[| 0].setValue(_arr[index]);
	}
	
	doUpdate();
}