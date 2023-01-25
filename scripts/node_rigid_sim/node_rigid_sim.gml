function Node_Rigid_Group(_x, _y, _group = -1) : Node_Collection(_x, _y, _group) constructor {
	name  = "RigidSim";
	color = COLORS.node_blend_simulation;
	icon  = THEME.rigidSim;
	
	ungroupable = false;
	update_on_frame = true;
	collIndex = irandom_range(1, 9999);
	
	if(!LOADING && !APPENDING && !CLONING) {
		var _render = nodeBuild("Node_Rigid_Render", 256, -32, self);
		var _output = nodeBuild("Node_Group_Output", 416, -32, self);
		
		_output.inputs[| 0].setFrom(_render.outputs[| 0]);
	}
	
	//physics_world_update_iterations(30);
	//physics_world_update_speed(100)
	
	static reset = function() {
		instance_destroy(oRigidbody);
		physics_pause_enable(true);
		
		time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, function() {
			for( var i = 0; i < ds_list_size(nodes); i++ ) {
				var n = nodes[| i];
				if(variable_struct_exists(n, "reset"))
					n.reset();
			}
			physics_pause_enable(false);
		}));
	}
	
	static onStep = function() {
		if(!ANIMATOR.is_playing)
			return;
		
		if(ANIMATOR.current_frame == 0) 
			reset();
		
		setRenderStatus(false);
		UPDATE |= RENDER_TYPE.full;
	}
}