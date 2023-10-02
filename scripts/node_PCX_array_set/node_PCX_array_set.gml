function Node_PCX_Array_Set(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name = "Array Set";
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone);
	
	inputs[| 1] = nodeValue("Index", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone);
	
	inputs[| 2] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone);
	
	outputs[| 0] = nodeValue("PCX", self, JUNCTION_CONNECT.output, VALUE_TYPE.PCXnode, noone);
	
	static update = function() {
		var _arr = getInputData(0);
		var _ind = getInputData(1);
		var _val = getInputData(2);
		
		outputs[| 0].setValue(new __funcTree("=", [ _arr, _ind ], _val));
	}
}