function Node_PCX_fn_Random(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name = "Random";
	
	inputs[| 0] = nodeValue("Min", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone);
	
	inputs[| 1] = nodeValue("Max", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone);
	
	inputs[| 2] = nodeValue("Integer", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("PCX", self, JUNCTION_CONNECT.output, VALUE_TYPE.PCXnode, noone);
	
	input_display_list = [ 2, 0, 1 ];
	
	static update = function() {
		var _min = inputs[| 0].getValue();
		var _max = inputs[| 1].getValue();
		var _int = inputs[| 2].getValue();
		
		outputs[| 0].setValue(new __funcTree(_int? "irandom" : "random", [ _min, _max ]));
	}
}