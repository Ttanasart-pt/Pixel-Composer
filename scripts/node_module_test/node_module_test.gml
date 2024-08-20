function Node_Module_SubModule(parent) : NodeModule(parent) constructor {
	newInput(0, nodeValue_Surface("Module input 0", parent));

	newInput(1, nodeValue("Module input 1", parent, CONNECT_TYPE.input, VALUE_TYPE.text, ""));
}

function Node_Module_Test(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Module test";
	
	newInput(0, nodeValue_Float("Static input", self, 0));
	
	outputs[0] = nodeValue_Output("Output", self, VALUE_TYPE.float, 0);
	
	//input_display_list = [ 0 ];
	
	setDynamicInput(1);
	
	static createNewInput = function() { #region
		var index = array_length(inputs);
		
		inputs[index] = new Node_Module_SubModule(self);
		
		return inputs[index];
	} if(!LOADING && !APPENDING) createNewInput(); #endregion
	
	static step = function() {}
	
	static update = function() {}
}