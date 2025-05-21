function Node_Iterate_Each(_x, _y, _group = noone) : Node_Iterator(_x, _y, _group) constructor {
	name  = "Loop Array";
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, [] ))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Array", VALUE_TYPE.any, [] ));
	
	custom_input_index  = array_length(inputs);
	custom_output_index = array_length(inputs);
	
	if(NODE_NEW_MANUAL) {
		var input  = nodeBuild("Node_Iterator_Each_Input", -256, -32, self);
		var output = nodeBuild("Node_Iterator_Each_Output", 256, -32, self);
		
		output.inputs[0].setFrom(input.outputs[0]);
	}
	
	static onStep = function() {
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
	}
	
	static doInitLoop = function() {
		var arrIn  = getInputData(0);
		var arrOut = outputs[0].getValue();
		
		if(array_length(arrOut) != array_length(arrIn))
			outputs[0].setValue([]);
	}
	
	static getIterationCount = function() {
		var arrIn = getInputData(0);
		var maxIter = is_array(arrIn)? array_length(arrIn) : 0;
		if(!is_real(maxIter)) maxIter = 1;
		
		return maxIter;
	}
}