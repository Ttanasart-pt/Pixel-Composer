function Node_Strand_Group_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "StrandSim";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	
	update_on_frame = true;
	
	if(!LOADING && !APPENDING && !CLONING) {
		var _create = nodeBuild("Node_Strand_Create", x,       y);
		var _render = nodeBuild("Node_Strand_Render", x + 256, y);
		
		_render.inputs[| 1].setFrom(_create.outputs[| 0]);
		
		addNode(_create);
		addNode(_render);
	}
}