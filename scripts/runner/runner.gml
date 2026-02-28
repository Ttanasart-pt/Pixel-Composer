function Runner() constructor {
	project        = new Project();
	project.online = true;
	
	io_node     = undefined;
	input_junc  = undefined;
	output_junc = undefined;
	curr_frame  = undefined;
	
	////- Process
	
	static processable = function() { return io_node != undefined; }
	
	static render = function(_frame = 0, _partial = true) {
		project.animator.current_frame  = _frame;
		
		try { RenderSync(project, _partial); }
		catch(e) { log_warning("UPDATE error", exception_print(e)); }
	}
	
	static process = function(_surf, _frame = 0) {
		project.animator.current_frame  = _frame;
		
		if(curr_frame == _frame) {
			project.animator.is_playing     = false;
			project.animator.frame_progress = false;
			return output_junc.getValue();
		}
		
		project.animator.is_playing     = true;
		project.animator.frame_progress = true;
		input_junc.setValue(_surf);
		
		// project.stepBegin();
		// project.step();
		// project.postStep();
		
		try { RenderSync(project); }
		catch(e) { log_warning("UPDATE: profile", exception_print(e)); }
		
		curr_frame = _frame;
		
		return output_junc.getValue();
	}
	
	////- Append
	
	static loadProject = function(_map) {
		var _p = PROJECT;

		SUPPRESS_NOTI = true;
		PROJECT  = project;
		PROJECT.deserialize(_map);
		__APPEND_MAP(_map, -4, [], false, false);
		PROJECT  = _p;
		SUPPRESS_NOTI = false;
		
		NodeTopoSort(project);
		
		return self;
	}
	
	static appendMap = function(_map) {
		var _p = PROJECT;
		
		SUPPRESS_NOTI = true;
		PROJECT  = project;
		__APPEND_MAP(_map, -4);
		PROJECT  = _p;
		SUPPRESS_NOTI = false;
		
		NodeTopoSort(project);
		
		return self;
	}
	
	static fetchIO = function() {
		if(array_length(project.nodes) < 1) return self;
		
		if(array_length(project.nodes) == 1) {
			var _grp = project.nodes[0];
			if(is(_grp, Node_Collection) && !array_empty(_grp.inputs) && !array_empty(_grp.outputs)) {
				io_node = _grp;
				io_node.checkPureFunction();
				
				input_junc  = _grp.inputs[0];
				output_junc = _grp.outputs[0];
			}
			
		} else {
			for( var i = 0, n = array_length(project.nodes); i < n; i++ ) {
				var _node = project.nodes[i];
				
				if(is(_node, Node_Export))
					output_junc = _node.outputs[0];
			}
			
		}
		
		
		return self;
	}
	
	static cleanup = function() {
		project.cleanup();
	}
	
}