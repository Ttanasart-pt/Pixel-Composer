function Node_Iterate_Each(_x, _y, _group = noone) : Node_Iterator(_x, _y, _group) constructor {
	name  = "Loop Array";
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [] )
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, [] );
	
	custom_input_index  = ds_list_size(inputs);
	custom_output_index = ds_list_size(inputs);
	
	if(NODE_NEW_MANUAL) { #region
		var input  = nodeBuild("Node_Iterator_Each_Input", -256, -32, self);
		var output = nodeBuild("Node_Iterator_Each_Output", 256, -32, self);
		
		output.inputs[| 0].setFrom(input.outputs[| 0]);
	} #endregion
	
	static onStep = function() { #region
		var type = inputs[| 0].value_from == noone? VALUE_TYPE.any : inputs[| 0].value_from.type;
		inputs[| 0].setType(type);
	} #endregion
	
	static doInitLoop = function() { #region
		var arrIn  = getInputData(0);
		var arrOut = outputs[| 0].getValue();
		
		if(array_length(arrOut) != array_length(arrIn))
			outputs[| 0].setValue([]);
	} #endregion
	
	static getIterationCount = function() { #region
		var arrIn = getInputData(0);
		var maxIter = is_array(arrIn)? array_length(arrIn) : 0;
		if(!is_real(maxIter)) maxIter = 1;
		
		return maxIter;
	} #endregion
}