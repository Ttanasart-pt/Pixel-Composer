enum ITERATION_STATUS {
	not_ready,
	loop,
	complete,
}

function Node_Iterator(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	willRestart = false;		//in the next getNextNode, reset all child nodes, use in loop.	
	
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
		
		LOG_LINE_IF(global.FLAG.render, "------------------< Loop begin >------------------");
	}
	
	static doInitLoop = function() {}
	
	static update = function(frame = PROJECT.animator.current_frame) { initLoop(); }
	
	static outputNextNode = function() {
		LOG_BLOCK_START();	
		LOG_IF(global.FLAG.render, "[outputNextNode] Get next node from Loop output");
		
		var _nodes = [];
		for( var i = 0; i < ds_list_size(nodes); i++ ) { // check if every node is updated
			if(!nodes[| i].rendered) {
				LOG_IF(global.FLAG.render, $"Skipped due to node {nodes[| i].internalName} not rendered.");
				LOG_BLOCK_END();
				return _nodes;
			}
		}
		
		if(willRestart) {
			LOG_IF(global.FLAG.render, $"Restart");
			resetRender();
			willRestart = false;
		}
		
		var _ren = iterationStatus();
		
		if(_ren == ITERATION_STATUS.loop) { //Go back to the beginning of the loop, reset render status for leaf node inside?
			//LOG_IF(global.FLAG.render, "Loop restart: iteration " + string(group.iterated));
			_nodes = array_append(_nodes, __nodeLeafList(getNodeList()));
		} else if(_ren == ITERATION_STATUS.complete) { //Go out of loop
			//LOG_IF(global.FLAG.render, "Loop completed get next node external");
			setRenderStatus(true);
			_nodes = getNextNodesExternal();
		} 
		
		LOG_BLOCK_END();
		
		return _nodes;
	}
	
	static getIterationCount = function() { return 0; }
	
	static iterationStatus = function() {
		if(iterated >= getIterationCount())
			return ITERATION_STATUS.complete;
		return ITERATION_STATUS.loop;
	}
	
	static iterationUpdate = function() {
		for( var i = 0; i < ds_list_size(nodes); i++ ) // check if every node is updated
			if(!nodes[| i].rendered) return;
		
		var maxIter = getIterationCount();
		iterated++;
		
		for( var i = 0; i < ds_list_size(nodes); i++ )
			nodes[| i].clearInputCache();
		
		if(iterated == maxIter) {
			LOG_LINE_IF(global.FLAG.render, $"------------------< Iteration update: {iterated} / {maxIter} [COMPLETE] >------------------");
			render_time = get_timer() - loop_start_time;
		} else if(iterated < maxIter) {
			LOG_LINE_IF(global.FLAG.render, $"------------------< Iteration update: {iterated} / {maxIter} [RESTART] >------------------");
			willRestart = true;
		}
	}
}