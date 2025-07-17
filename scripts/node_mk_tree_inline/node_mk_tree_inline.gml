function Node_MK_Tree_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "MK Tree";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	is_simulation = true;
	
	input_node_types   = [ Node_MK_Tree_Root, Node_MK_Tree_Path_Root   ];
	output_node_types  = [ Node_MK_Tree_Render, Node_MK_Tree_Branch_To_Path ];
	
	if(NODE_NEW_MANUAL) {
		var _branch = nodeBuild("Node_MK_Tree_Root",   x,       y, self);
		var _render = nodeBuild("Node_MK_Tree_Render", x + 160, y, self);
		
		_render.inputs[0].setFrom(_branch.outputs[0]);
		
		addNode(_branch);
		addNode(_render);
	}
	
	seed       = 0;
	gravityDir = -90;
	
	newInput(0, nodeValueSeed(VALUE_TYPE.integer));
	newInput(1, nodeValue_Rotation( "Gravity", -90 ));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0,
		[ "Physics",   false ], 1, 
	];
	
	static update = function() {
		seed       = inputs[0].getValue();
		gravityDir = inputs[1].getValue();
	}
	
}