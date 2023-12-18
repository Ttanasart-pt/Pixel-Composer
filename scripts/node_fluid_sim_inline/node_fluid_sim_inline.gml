function Node_Fluid_Group_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "SmokeSim";
	color = COLORS.node_blend_smoke;
	icon  = THEME.smoke_sim;
	
	if(!LOADING && !APPENDING && !CLONING) {
		var _domain = nodeBuild("Node_Fluid_Domain", x,       y);
		var _render = nodeBuild("Node_Fluid_Render", x + 320, y);
		
		_render.inputs[| 0].setFrom(_domain.outputs[| 0]);
		
		addNode(_domain);
		addNode(_render);
	}
}