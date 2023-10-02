//Make an iterator_* parent???

function Node_Iterate_Filter(_x, _y, _group = noone) : Node_Iterator(_x, _y, _group) constructor {
	name = "Filter Array";
	color = COLORS.node_blend_loop;
	icon  = THEME.loop;
	
	reset_all_child = true;
	combine_render_time = false;
	iterated = 0;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [] )
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, noone );
	
	custom_input_index = ds_list_size(inputs);
	custom_output_index = ds_list_size(inputs);
	loop_start_time = 0;
	ALWAYS_FULL = true;
	
	if(!LOADING && !APPENDING && !CLONING) {
		var input  = nodeBuild("Node_Iterator_Filter_Input", -256, -32, self);
		var output = nodeBuild("Node_Iterator_Filter_Output", 256, -32, self);
		
		output.inputs[| 0].setFrom(input.outputs[| 0]);
	}
	
	static onStep = function() {
		var type = inputs[| 0].value_from == noone? VALUE_TYPE.any : inputs[| 0].value_from.type;
		inputs[| 0].type = type;
	}
	
	static doInitLoop = function() {
		var arrIn  = getInputData(0);
		var arrOut = outputs[| 0].getValue();
		
		surface_array_free(arrOut);
		outputs[| 0].setValue([])
	}
	
	static getIterationCount = function() {
		var arrIn = getInputData(0);
		var maxIter = is_array(arrIn)? array_length(arrIn) : 0;
		if(!is_real(maxIter)) maxIter = 1;
		
		return maxIter;
	}
	
	PATCH_STATIC
}