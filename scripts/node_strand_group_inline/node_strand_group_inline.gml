function Node_Strand_Group_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "StrandSim";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	
	output_node_types   = [ Node_Strand_Render ];
	
	is_simulation   = true;
	update_on_frame = true;
	
	if(NODE_NEW_MANUAL) {
		var _create = nodeBuild("Node_Strand_Create", x,       y, self);
		var _render = nodeBuild("Node_Strand_Render", x + 256, y, self);
		
		_render.inputs[1].setFrom(_create.outputs[0]);
		
		addNode(_create);
		addNode(_render);
	}
}