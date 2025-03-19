function Node_Feedback_Input(_x, _y, _group = noone) : Node_Group_Input(_x, _y, _group) constructor {
	name        = "Feedback Input";
	color       = COLORS.node_blend_feedback;
	is_group_io = true;
	setDimension(96, 48);
	
	loopable    = false;
	feedbackOut = noone;
	
	outputs[0].getValueDefault = method(outputs[0], outputs[0].getValueRecursive); //Get value from outside loop
	outputs[0].getValueRecursive = function(arr, _time) {
		if(!is(feedbackOut, NodeValue)) return;
		
		var _vto  = feedbackOut.getJunctionTo();
		var _jout = array_safe_get(_vto, 0, noone);
		if(_jout == noone) return;
		
		if(CURRENT_FRAME > 0 && _jout.node.cache_value != noone) { //use cache from output 
			arr[@ 0] = _jout.node.cache_value;
			arr[@ 1] = inParent;
			return;
		}
		
		outputs[0].getValueDefault(arr);
	}
	
	newOutput(1, nodeValue_Output("Feedback loop", self, VALUE_TYPE.node, 0).nonForward());
	feedbackOut = outputs[1];
}