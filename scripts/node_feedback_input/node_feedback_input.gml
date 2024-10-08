function Node_Feedback_Input(_x, _y, _group = noone) : Node_Group_Input(_x, _y, _group) constructor {
	name        = "Feedback Input";
	color       = COLORS.node_blend_feedback;
	is_group_io = true;
	setDimension(96, 32 + 24 * 2);
	
	outputs[0].getValueDefault = method(outputs[0], outputs[0].getValueRecursive); //Get value from outside loop
	outputs[0].getValueRecursive = function(arr, _time) {
		var _node_output = noone;
		for( var i = 0; i < array_length(outputs[1].value_to); i++ ) {
			var vt = outputs[1].value_to[i];
			if(vt.value_from == outputs[1])
				_node_output = vt;
		}
		
		if(CURRENT_FRAME > 0 && _node_output != noone && _node_output.node.cache_value != noone) { //use cache from output 
			arr[@ 0] = _node_output.node.cache_value;
			arr[@ 1] = inParent;
			return;
		}
		
		outputs[0].getValueDefault(arr);
	}
	
	newOutput(1, nodeValue_Output("Feedback loop", self, VALUE_TYPE.node, 0).nonForward());
}