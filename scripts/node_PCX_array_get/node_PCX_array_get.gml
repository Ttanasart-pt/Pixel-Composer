function Node_PCX_Array_Get(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name = "Array Get";
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone);
	
	inputs[| 1] = nodeValue("Index", self, JUNCTION_CONNECT.input, VALUE_TYPE.PCXnode, noone);
	
	outputs[| 0] = nodeValue("PCX", self, JUNCTION_CONNECT.output, VALUE_TYPE.PCXnode, noone);
	
	static update = function() {
		var _arr = getInputData(0);
		var _ind = getInputData(1);
		
		outputs[| 0].setValue(new __funcTree("@", _arr, _ind));
	}
}