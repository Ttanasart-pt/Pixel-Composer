function Node_Iterate(_x, _y, _group = noone) : Node_Iterator(_x, _y, _group) constructor {
	name  = "Loop";
	
	inputs[| 0] = nodeValue("Repeat", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.uncache();
	
	custom_input_index = ds_list_size(inputs);
	
	if(!LOADING && !APPENDING && !CLONING) { #region
		var input  = nodeBuild("Node_Iterator_Input", -256, -32, self);
		var output = nodeBuild("Node_Iterator_Output", 256, -32, self);
		
		input.inputs[| 2].setValue(4);
		output.inputs[| 1].setFrom(input.outputs[| 1]);
	} #endregion
	
	static getIterationCount = function() { return getInputData(0); }
}