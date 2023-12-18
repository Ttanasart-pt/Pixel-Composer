function Node_VFX_Group_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "VFX";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	update_on_frame    = true;
	
	if(!LOADING && !APPENDING && !CLONING) { #region
		var input  = nodeBuild("Node_VFX_Spawner",  x,       y);
		var output = nodeBuild("Node_VFX_Renderer", x + 256, y);
		
		output.inputs[| output.input_fix_len + 1].setFrom(input.outputs[| 0]);
		
		addNode(input);
		addNode(output);
	} #endregion
	
}