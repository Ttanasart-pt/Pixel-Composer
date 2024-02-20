function Node_FLIP_Group_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "FLIP Fluid";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	
	is_simulation   = true;
	update_on_frame = true;
	
	if(!LOADING && !APPENDING && !CLONING) {
		var _domain = nodeBuild("Node_FLIP_Domain",  x,       y);
		var _spawn  = nodeBuild("Node_FLIP_Spawner", x + 160, y);
		var _render = nodeBuild("Node_FLIP_Render",  x + 320, y);
		
		_spawn.inputs[| 0].setFrom(_domain.outputs[| 0]);
		_render.inputs[| 0].setFrom(_spawn.outputs[| 0]);
		
		addNode(_domain);
		addNode(_spawn);
		addNode(_render);
	}
}