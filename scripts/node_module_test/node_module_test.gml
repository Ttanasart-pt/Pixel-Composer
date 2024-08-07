function Node_Module_SubModule(parent) : NodeModule(parent) constructor {
	inputs[| 0] = nodeValue_Surface("Module input 0", parent);

	inputs[| 1] = nodeValue("Module input 1", parent, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
}

function Node_Module_Test(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Module test";
	
	inputs[| 0] = nodeValue("Static input", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	//input_display_list = [ 0 ];
	
	setDynamicInput(1);
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		
		inputs[| index] = new Node_Module_SubModule(self);
		
		return inputs[| index];
	} if(!LOADING && !APPENDING) createNewInput(); #endregion
	
	static step = function() {}
	
	static update = function() {}
}