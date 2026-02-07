enum ITERATION_STATUS {
	not_ready,
	loop,
	complete,
}

function Node_Iterator(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	color = COLORS.node_blend_loop;
	icon  = THEME.loop;
	
	willRestart         = false;		//in the next getNextNode, reset all child nodes, use in loop.	
	managedRenderOrder  = true;
	reset_all_child     = true;
	combine_render_time = false;
	loop_start_time     = 0;
	
	iterated = 0;
	
	static isActiveDynamic = function(frame = CURRENT_FRAME) {
		for( var i = 0, n = array_length(nodes); i < n; i++ )
			if(nodes[i].isActiveDynamic(frame)) return true;
		
		return false;
	}
	
	static initLoop = function() {
		resetRender();
		
		iterated = 0;
		loop_start_time = get_timer();
		var node_list   = getNodeList();
		
		for( var i = 0; i < ds_list_size(node_list); i++ ) {
			var _node = node_list[| i];
			if(variable_struct_exists(_node, "initLoop"))
				_node.initLoop();
		}
		
		doInitLoop();
		if(global.FLAG.render) LOG_LINE("------------------< Loop begin >------------------");
	}
	
	static doInitLoop = function() {}
	
	static update = function(frame = CURRENT_FRAME) { initLoop(); }
	
	static outputNextNode = function() {
		LOG_BLOCK_START	
		if(global.FLAG.render == 1) LOG("[outputNextNode] Get next node from Loop output");
		
		var _nodes = [];
		
		for( var i = 0; i < array_length(nodes); i++ ) { // check if every node is updated
			if(!nodes[i].rendered) {
				if(global.FLAG.render == 1) LOG($"Skipped due to node {nodes[i].internalName} not rendered.");
				LOG_BLOCK_END
				return _nodes;
			}
		}
		
		if(willRestart) {
			if(global.FLAG.render == 1) LOG($"Restart");
			resetRender();
			willRestart = false;
		}
		
		var _ren = iterationStatus();
		
		if(_ren == ITERATION_STATUS.loop) { //Go back to the beginning of the loop, reset render status for leaf node inside?
			if(global.FLAG.render == 1) LOG($"Loop restart: iteration {iterated}");
			_nodes = array_append(_nodes, __nodeLeafList(getNodeList()));
			
		} else if(_ren == ITERATION_STATUS.complete) { //Go out of loop
			if(global.FLAG.render == 1) LOG("Loop completed get next node external");
			setRenderStatus(true);
			_nodes = getNextNodesExternal();
		} 
		
		LOG_BLOCK_END
		return _nodes;
	}
	
	static getIterationCount = function() { return 0; }
	
	static iterationStatus = function() {
		if(iterated >= getIterationCount())
			return ITERATION_STATUS.complete;
		return ITERATION_STATUS.loop;
	}
	
	static iterationUpdate = function() {
		var maxIter = getIterationCount();
		
		for( var i = 0; i < array_length(nodes); i++ ) // check if every node is updated
			if(!nodes[i].rendered) {
				if(global.FLAG.render) LOG_LINE($"------------------< Iteration update: {iterated} / {maxIter} [RENDER FAILED by {nodes[i]}] >------------------");
				return;
			}
		
		iterated++;
		
		for( var i = 0; i < array_length(nodes); i++ )
			nodes[i].clearInputCache();
		
		if(iterated == maxIter) {
			if(global.FLAG.render) LOG_LINE($"------------------< Iteration update: {iterated} / {maxIter} [COMPLETE] >------------------");
			render_time = get_timer() - loop_start_time;
		} else if(iterated < maxIter) {
			if(global.FLAG.render) LOG_LINE($"------------------< Iteration update: {iterated} / {maxIter} [RESTART] >------------------");
			willRestart = true;
		}
	}
}