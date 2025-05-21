function Node_PCX_Array_Set(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name = "Array Set";
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(1, nodeValue("Index", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newInput(2, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.PCXnode, noone));
	
	newOutput(0, nodeValue_Output("PCX", VALUE_TYPE.PCXnode, noone));
	
	static update = function() {
		var _arr = getInputData(0);
		var _ind = getInputData(1);
		var _val = getInputData(2);
		
		outputs[0].setValue(new __funcTree("=", [ _arr, _ind ], _val));
	}
}