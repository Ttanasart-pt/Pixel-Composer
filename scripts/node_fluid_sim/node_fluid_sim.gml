function Node_Fluid_Group(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "FluidSim";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	
	ungroupable = false;
	update_on_frame = true;
	
	if(!LOADING && !APPENDING && !CLONING) {
		var _domain = nodeBuild("Node_Fluid_Domain", -384, -32, self);
		var _update = nodeBuild("Node_Fluid_Update",    0, -32, self);
		var _render = nodeBuild("Node_Fluid_Render",  128, -32, self);
		var _output = nodeBuild("Node_Group_Output",  384, -32, self);
		
		_output.inputs[| 0].setFrom(_render.outputs[| 0]);
		_render.inputs[| 0].setFrom(_update.outputs[| 0]);
		_update.inputs[| 0].setFrom(_domain.outputs[| 0]);
	}
	
	static onStep = function() {
		RETURN_ON_REST
		
		setRenderStatus(false);
		RENDER_ALL
	}
	
	PATCH_STATIC
}