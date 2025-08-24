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
	
	static doInitLoop = function() {
		var arrIn  = getInputData(0);
		var arrOut = outputs[0].getValue();
		var _iLen  = array_length(arrIn);
		
		if(inputs[0].type == VALUE_TYPE.surface) {
			surface_array_free(arrOut);
			outputs[0].setValue([]);
			
		} else {
			arrOut = array_verify(arrOut, _iLen);
			outputs[0].setValue(arrOut);
		}
		
	}
	
	static getIterationCount = function() {
		var arrIn = getInputData(0);
		var maxIter = is_array(arrIn)? array_length(arrIn) : 0;
		if(!is_real(maxIter)) maxIter = 1;
		
		return maxIter;
	}
	
	static update = function(frame = CURRENT_FRAME) { 
		inputs[0].setType(inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type);
		
		initLoop(); 
	}
	
}