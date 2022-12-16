function Node_VFX_Group(_x, _y, _group = -1) : Node_Collection(_x, _y, _group) constructor {
	name  = "VFX";
	color = COLORS.node_blend_vfx;
	ungroupable = false;
	
	if(!LOADING && !APPENDING) {
		var input  = nodeBuild("Node_VFX_Spawner", -256, -32, self);
		var renderer = nodeBuild("Node_VFX_Renderer", 256, -32, self);
		var output = nodeBuild("Node_Group_Output", 256 + 32 * 5, -32, self);
		
		renderer.inputs[| renderer.input_index].setFrom(input.outputs[| 0]);
		output.inputs[| 0].setFrom(renderer.outputs[| 0]);
	}
}