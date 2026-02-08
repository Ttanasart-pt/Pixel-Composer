function Runner() constructor {
	project        = new Project();
	project.online = true;
	
	io_node     = undefined;
	input_junc  = undefined;
	output_junc = undefined;
	curr_frame  = undefined;
	
	////- Process
	
	static processable = function() { return io_node != undefined; }
	
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
		if(array_length(project.nodes) != 1) return self;
		
		var _grp = project.nodes[0];
		if(is(_grp, Node_Collection) && !array_empty(_grp.inputs) && !array_empty(_grp.outputs)) {
			io_node = _grp;
			io_node.checkPureFunction();
			
			input_junc  = _grp.inputs[0];
			output_junc = _grp.outputs[0];
		}
		
		return self;
	}
	
	static cleanup = function() {
		project.cleanup();
	}
	
}