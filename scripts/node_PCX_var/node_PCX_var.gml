function Node_PCX_var(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name = "Variable";
	
	newInput(0, nodeValue_Text("Name", self, ""));
	
	newInput(1, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, -1));
	
	outputs[0] = nodeValue_Output("PCX", self, VALUE_TYPE.PCXnode, noone);
	
	static update = function() {
		var _name = getInputData(0);
		var _val  = getInputData(1);
		
		outputs[0].setValue(new __funcTree("=", _name, _val));
	}
}