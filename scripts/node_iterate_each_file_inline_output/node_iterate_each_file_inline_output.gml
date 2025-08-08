function Node_Iterate_Each_File_Inline_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Loop Output";
	color = COLORS.node_blend_loop;
	loop  = noone;
	setDimension(96, 48);
	
	loopable = false;
	clonable = false;
	
	inline_output        = false;
	inline_parent_object = "Node_Iterate_Each_Inline";
	manual_ungroupable	 = false;
	
	newInput(0, nodeValue_Surface("Value Out")).setVisible(true, true);
	
	static getNextNodes = function(checkLoop = false) {
		if(loop.bypassNextNode())
			return loop.getNextNodes();
		return getNextNodesRaw();
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(!is(loop, Node_Iterate_Each_File_Inline)) return;
		
	}
}