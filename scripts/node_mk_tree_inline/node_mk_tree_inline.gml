function Node_MK_Tree_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "MK Tree";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	is_simulation = true;
	
	input_node_types   = [ Node_MK_Tree_Root   ];
	output_node_types  = [ Node_MK_Tree_Render ];
	
	if(NODE_NEW_MANUAL) {
		var _branch = nodeBuild("Node_MK_Tree_Root",   x,       y, self);
		var _render = nodeBuild("Node_MK_Tree_Render", x + 160, y, self);
		
		_render.inputs[0].setFrom(_branch.outputs[0]);
		
		addNode(_branch);
		addNode(_render);
	}
	
	seed = 0;
	
	newInput(0, nodeValueSeed(VALUE_TYPE.integer));
	
	static update = function() {
		seed = inputs[0].getValue();
	}
	
	static setRenderStatus = function(result) {
		for( var i = 0, n = array_length(nodes); i < n; i++ ) 
			nodes[i].rendered = result;
	}
}