function Node_Module_SubModule(parent) : NodeModule(parent) constructor {
	newInput(0, nodeValue_Surface("Module input 0"));
	newInput(1, nodeValue("Module input 1", parent, CONNECT_TYPE.input, VALUE_TYPE.text, ""));
}

function Node_Module_Test(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Module test";
	
	newInput(0, nodeValue_Float("Static input", 0));
	
	newOutput(0, nodeValue_Output("Output", VALUE_TYPE.float, 0));
	
	//input_display_list = [ 0 ];
	
	setDynamicInput(1);
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		inputs[index] = new Node_Module_SubModule(self);
		
		return inputs[index];
	} if(!LOADING && !APPENDING) createNewInput();
	
	static step = function() {}
	
	static update = function() {}
}