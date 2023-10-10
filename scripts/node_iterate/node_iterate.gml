function Node_Iterate(_x, _y, _group = noone) : Node_Iterator(_x, _y, _group) constructor {
	name = "Loop";
	color = COLORS.node_blend_loop;
	icon  = THEME.loop;
	
	reset_all_child     = true;
	combine_render_time = false;
	managedRenderOrder  = true;
	iterated = 0;
	
	inputs[| 0] = nodeValue("Repeat", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.uncache();
	
	custom_input_index = ds_list_size(inputs);
	loop_start_time = 0;
	ALWAYS_FULL = true;
	
	if(!LOADING && !APPENDING && !CLONING) {
		var input  = nodeBuild("Node_Iterator_Input", -256, -32, self);
		var output = nodeBuild("Node_Iterator_Output", 256, -32, self);
		
		input.inputs[| 2].setValue(4);
		output.inputs[| 2].setFrom(input.outputs[| 1]);
	}
	
	static getIterationCount = function() { return getInputData(0); }
	
	PATCH_STATIC
}