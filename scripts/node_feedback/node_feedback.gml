function Node_Feedback(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "Feedback";
	color = COLORS.node_blend_feedback;
	icon  = THEME.feedback;
	
	update_on_frame = true;
	reset_all_child = true;
	
	if(!LOADING && !APPENDING && !CLONING) {
		var input  = nodeBuild("Node_Feedback_Input", -256, -32, self);
		var output = nodeBuild("Node_Feedback_Output", 256, -32, self);
		
		input.inputs[| 2].setValue(4);
		output.inputs[| 0].setFrom(input.outputs[| 0]);
		output.inputs[| 1].setFrom(input.outputs[| 1]);
	}
	
	static getNextNodes = function() {
		var allReady = true;
		for(var i = custom_input_index; i < ds_list_size(inputs); i++) {
			var _in = inputs[| i].from;
			if(!_in.isRenderActive()) continue;
			
			allReady &= _in.isRenderable()
		}
		
		if(!allReady) return [];
		
		return __nodeLeafList(getNodeList());
	}
	
	PATCH_STATIC
}