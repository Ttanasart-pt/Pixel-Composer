function Node_Iterator_Sort_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Swap result";
	color = COLORS.node_blend_loop;
	
	manual_deletable = false;
	
	newInput(0, nodeValue_Bool("Result", self, false ))
		.setVisible(true, true);
	
	attributes.sort_inputs = 0;
	
	static getNextNodes = function() { return []; }
	
	static step = function() {}
	
	static update = function(frame = CURRENT_FRAME) {}
}