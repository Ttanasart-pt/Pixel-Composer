function Node_create_Array(_x, _y) {
	var node = new Node_Array(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Array(_x, _y) : Node(_x, _y) constructor {
	name		= "Array";
	previewable = false;
	
	input_size = 0;
	input_max  = 8;
	
	w = 96;
	
	for(var i = 0; i < input_max; i++) {
		inputs[| i] = nodeValue(i, "Value " + string(i), self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0);
	}
	
	outputs[| 0] = nodeValue(0, "Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, []);
	
	static update = function() {
		var res = array_create(input_size);
		
		input_size = 0;
		for(var i = 0; i < input_max; i++) {
			if(inputs[| i].value_from) {
				res[i] = inputs[| i].getValue();
				input_size = i + 1;
			}
		}
		if(input_size < input_max) {
			inputs[| input_size].show_in_inspector = true;
		}
		outputs[| 0].setValue(res);
	}
	doUpdate();
}