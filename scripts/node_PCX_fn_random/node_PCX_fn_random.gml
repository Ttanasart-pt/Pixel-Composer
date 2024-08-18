function Node_PCX_fn_Random(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name = "Random";
	
	newInput(0, nodeValue("Min", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(1, nodeValue("Max", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(2, nodeValue_Bool("Integer", self, false));
	
	outputs[0] = nodeValue_Output("PCX", self, VALUE_TYPE.PCXnode, noone);
	
	input_display_list = [ 2, 0, 1 ];
	
	static update = function() {
		var _min = getInputData(0);
		var _max = getInputData(1);
		var _int = getInputData(2);
		
		outputs[0].setValue(new __funcTree(_int? "irandom" : "random", [ _min, _max ]));
	}
}