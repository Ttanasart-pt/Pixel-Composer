function Node_Strand_Group(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "StrandSim";
	color = COLORS.node_blend_strand;
	icon  = THEME.strandSim;
	
	manual_ungroupable	 = false;
	ungroupable          = false;
	update_on_frame      = true;
	
	if(!LOADING && !APPENDING && !CLONING) {
		var _create = nodeBuild("Node_Strand_Create", -384, -32, self);
		var _update = nodeBuild("Node_Strand_Update",    0, -32, self);
		var _render = nodeBuild("Node_Strand_Render",  128, -32, self);
		var _output = nodeBuild("Node_Group_Output",   384, -32, self);
		
		_output.inputs[| 0].setFrom(_render.outputs[| 0]);
		_render.inputs[| 1].setFrom(_update.outputs[| 0]);
		_update.inputs[| 0].setFrom(_create.outputs[| 0]);
	}
	
	static onStep = function() {
		RETURN_ON_REST
		
		setRenderStatus(false);
		RENDER_ALL
	}
}