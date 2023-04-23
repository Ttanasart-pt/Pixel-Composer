function Node_Iterator_Sort_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Swap result";
	color = COLORS.node_blend_loop;
	
	manual_deletable = false;
	
	inputs[| 0] = nodeValue("Result", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
		.setVisible(true, true);
		
	static getNextNodes = function() {
		return [];
	}
	
	static step = function() {}
	
	static update = function(frame = ANIMATOR.current_frame) {
		//print(display_name + ": " + string(inputs[| 0].getValue()));
	}
}