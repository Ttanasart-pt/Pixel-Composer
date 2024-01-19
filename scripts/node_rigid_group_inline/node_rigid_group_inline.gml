function Node_Rigid_Group_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "RigidSim";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	
	is_simulation      = true;
	manual_ungroupable = false;
	
	if(!LOADING && !APPENDING && !CLONING) {
		var _object = nodeBuild("Node_Rigid_Object", x,       y);
		var _output = nodeBuild("Node_Rigid_Render", x + 160, y);
		
		_output.inputs[| 2].setFrom(_object.outputs[| 0])
		
		addNode(_object);
		addNode(_output);
	}
}