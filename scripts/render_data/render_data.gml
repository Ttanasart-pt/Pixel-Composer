enum RENDER_TYPE {
	none = 0,
	partial = 1,
	full = 2
}

#region globalvar
	globalvar UPDATE, RENDER_QUEUE, RENDER_ORDER, UPDATE_RENDER_ORDER, LIVE_UPDATE;
	
	LIVE_UPDATE            = false;
	UPDATE_RENDER_ORDER    = false;
	
	#macro RENDER_ALL_REORDER	UPDATE_RENDER_ORDER = true; UPDATE |= RENDER_TYPE.full;
	#macro RENDER_ALL									    UPDATE |= RENDER_TYPE.full;
	#macro RENDER_PARTIAL								    UPDATE |= RENDER_TYPE.partial;
	
	global.getvalue_hit = 0;
#endregion

function ResetAllNodesRender() {
	LOG_IF(global.FLAG.render == 1, $"XXXXXXXXXXXXXXXXXXXX RESETTING ALL NODES [frame {CURRENT_FRAME}] XXXXXXXXXXXXXXXXXXXX");
	
	array_foreach(PROJECT.allNodes, function(_node) { 
		if(!is_instanceof(_node, Node)) return;
		
		_node.setRenderStatus(false);
		for( var i = 0, n = array_length(_node.inputs); i < n; i++ ) 
			_node.inputs[i].resetCache();
		return;
	});
	
}

function NodeTopoSort() {
	LOG_IF(global.FLAG.render == 1, $"======================= RESET TOPO =======================")
	
	var amo  = array_length(PROJECT.allNodes);
	var _t   = get_timer();
	
	array_foreach(PROJECT.allNodes, function(_node) { 
		_node.clearTopoSorted();
		if(is(_node, Node_Collection)) _node.refreshNodes();
		return 0;
	});
	
	PROJECT.nodeTopo   = [];
	PROJECT.renderList = [];
	PROJECT.useRenderList = true;
	__topoSort(PROJECT.nodeTopo, PROJECT.nodes);
	
	LOG_IF(global.FLAG.render == 1, $"+++++++ Topo Sort Completed: {array_length(PROJECT.nodeTopo)}/{amo} nodes sorted in {(get_timer() - _t) / 1000} ms +++++++");
}

function NodeListSort(_nodeList) {
	array_foreach(_nodeList, function(node) {
		node.clearTopoSorted();
		return 0;
	});
	
	var _arr = [];
	__topoSort(_arr, _nodeList);
	return _arr;
}

function __sortNode(_arr, _node) {
	if(_node.topoSorted) return;
	
	var _parents = [];
	var _prev    = _node.getPreviousNodes();
		
	for( var i = 0, n = array_length(_prev); i < n; i++ ) {
		var _in = _prev[i];
		if(_in == noone || _in.topoSorted) continue;
			
		array_push(_parents, _in);
	}
		
	// print($"        > Checking {_node.name}: {array_length(_parents)}");
		
	if(is_instanceof(_node, Node_Collection) && !_node.managedRenderOrder)
		__topoSort(_arr, _node.nodes);
	
	for( var i = 0, n = array_length(_parents); i < n; i++ ) 
		__sortNode(_arr, _parents[i]);
	
	if(!_node.topoSorted) {
		array_push(_arr, _node);
		_node.topoSorted  = true;
		_node.__nextNodes = noone;
			
		// print($"        > Adding > {_node.name}");
	}
}

function __topoSort(_arr, _nodeArr) {
	var _root     = [];
	var _leftOver = [];
	var _global   = _nodeArr == PROJECT.nodes;
	__temp_nodeList = _nodeArr;
	
	for( var i = 0, n = array_length(_nodeArr); i < n; i++ ) {
		var _node   = _nodeArr[i];
		var _isRoot = true;
		
		if(is_instanceof(_node, Node_Collection_Inline) && !_node.is_root) {
			array_push(_leftOver, _node);
			continue;
		}
		
		if(_node.attributes.show_update_trigger && !array_empty(_node.updatedOutTrigger.getJunctionTo())) {
			_isRoot = false;
			
		} else {
			for( var j = 0, m = array_length(_node.outputs); j < m; j++ ) {
				var _to = _node.outputs[j].getJunctionTo();
				
				if(_global) _isRoot &= array_empty(_to);
				else        _isRoot &= !array_any(_to, function(_val) { return array_exists(__temp_nodeList, _val.node); } );
				
				if(!_isRoot) break;
			}
		}
		
		if(_isRoot) array_push(_root, _node);
	}
	
	// print($"Root: {_root}");
	
	for( var i = 0, n = array_length(_root); i < n; i++ ) 
		__sortNode(_arr, _root[i]);
	
	for( var i = 0, n = array_length(_leftOver); i < n; i++ ) {
		if(!_leftOver[i].topoSorted)
			array_insert(_arr, 0, _leftOver[i]);
	}
	
	__temp_nodeList = [];
}

function __nodeLeafList(_arr) {
	var nodes     = [];
	var nodeNames = [];
	
	for( var i = 0, n = array_length(_arr); i < n; i++ ) {
		var _node = _arr[i];
		
		if(!_node.active)			 { LOG_LINE_IF(global.FLAG.render == 1, $"Reject {_node.internalName} [inactive]");       continue; }
		if(!_node.isLeafList(_arr))  { LOG_LINE_IF(global.FLAG.render == 1, $"Reject {_node.internalName} [not leaf]");       continue; }
		if(!_node.isRenderable())    { LOG_LINE_IF(global.FLAG.render == 1, $"Reject {_node.internalName} [not renderable]"); continue; }
		
		array_push(nodes, _node);
		array_push(nodeNames, _node.internalName);
	}
	
	LOG_LINE_IF(global.FLAG.render == 1, $"Push node {nodeNames} to queue");
	return nodes;
}

function __nodeIsRenderLeaf(_node) {
	if(is_undefined(_node))									 { LOG_IF(global.FLAG.render == 1, $"Skip undefiend		  [{_node}]"); return false; }
	if(!is_instanceof(_node, Node))							 { LOG_IF(global.FLAG.render == 1, $"Skip non-node		  [{_node}]"); return false; }
	
	if(_node.is_group_io)									 { LOG_IF(global.FLAG.render == 1, $"Skip group IO		  [{_node.internalName}]"); return false; }
	
	if(!_node.active)										 { LOG_IF(global.FLAG.render == 1, $"Skip inactive         [{_node.internalName}]"); return false; }
	if(!_node.isRenderActive())								 { LOG_IF(global.FLAG.render == 1, $"Skip render inactive  [{_node.internalName}]"); return false; }
	if(!_node.attributes.update_graph)						 { LOG_IF(global.FLAG.render == 1, $"Skip non-auto update  [{_node.internalName}]"); return false; }
			
	if(_node.passiveDynamic) { _node.forwardPassiveDynamic();  LOG_IF(global.FLAG.render == 1, $"Skip passive dynamic  [{_node.internalName}]"); return false; }
	
	if(!_node.isActiveDynamic())							 { LOG_IF(global.FLAG.render == 1, $"Skip rendered static  [{_node.internalName}]"); return false; }
	if(_node.inline_context != noone && _node.inline_context.managedRenderOrder) return false;
	
	return true;
}

function Render(partial = false, runAction = false) {
	// node_auto_organize(PROJECT.nodes);
	
	LOG_END();

	LOG_BLOCK_START();
	LOG_IF(global.FLAG.render, $"============================== RENDER START [{partial? "PARTIAL" : "FULL"}] [frame {CURRENT_FRAME}] ==============================");
	
	// global.getvalue_hit = 0;
	
	// if(PROJECT.useRenderList && !array_empty(PROJECT.renderList)) {
	// 	for( var i = 0, n = array_length(PROJECT.renderList); i < n; i++ ) {
			
	// 		var render_pt = get_timer();
	// 		var rendering = PROJECT.renderList[i];
			
	// 		rendering.doUpdate();
	// 		rendering.getNextNodes(true);
			
	// 		if(PROFILER_STAT) rendering.summarizeReport(render_pt);
	// 	}
	// 	return;
	// } 
	
	try {
		var t  = get_timer();
		var t1 = get_timer();
		
		var _render_time = 0;
		var _leaf_time   = 0;
		
		var rendering = noone;
		var error     = 0;
		var reset_all = !partial;
		var renderable;
		
		if(reset_all) {
			LOG_IF(global.FLAG.render == 1, $"xxxxxxxxxx Resetting {array_length(PROJECT.nodeTopo)} nodes xxxxxxxxxx");
			
			for (var i = 0, n = array_length(PROJECT.allNodes); i < n; i++) {
				var _node = PROJECT.allNodes[i];
				_node.setRenderStatus(false);
			}
		}
		
		// get leaf node
		LOG_IF(global.FLAG.render == 1, $"----- Finding leaf from {array_length(PROJECT.nodeTopo)} nodes -----");
		RENDER_QUEUE.clear();
		array_foreach(PROJECT.nodeTopo, function(n) /*=>*/ { 
			n.passiveDynamic = false; 
			n.__nextNodes    = noone;
			n.render_time    = 0;
		});
		
		array_foreach(PROJECT.nodeTopo, function(n) /*=>*/ { 
			if(!__nodeIsRenderLeaf(n)) return;
			
			LOG_IF(global.FLAG.render == 1, $"    Found leaf [{n.internalName}]");
			RENDER_QUEUE.enqueue(n);
			n.forwardPassiveDynamic();
		});
		
		_leaf_time = get_timer() - t;
		LOG_IF(global.FLAG.render >= 1, $"Get leaf complete: found {RENDER_QUEUE.size()} leaves in {(get_timer() - t) / 1000} ms."); t = get_timer();
		LOG_IF(global.FLAG.render == 1,  "================== Start rendering ==================");
		
		// render forward
		while(!RENDER_QUEUE.empty()) {
			LOG_BLOCK_START();
			// LOG_IF(global.FLAG.render == 1, $"➤➤➤➤➤➤ CURRENT RENDER QUEUE {RENDER_QUEUE} [{RENDER_QUEUE.size()}] ");
			
			rendering  = RENDER_QUEUE.dequeue();
			renderable = rendering.isRenderable();
			
			if(is(rendering, Node_Iterate_Sort_Inline)) 
				PROJECT.useRenderList = false;
			// LOG_IF(global.FLAG.render == 1, $"Rendering {rendering.internalName} ({rendering.display_name}) : {renderable? "Update" : "Pass"} ({rendering.rendered})");
			
			if(renderable) {
				var render_pt = get_timer();
				rendering.doUpdate(); 
				array_push(PROJECT.renderList, rendering);
				_render_time += get_timer() - render_pt;
				
				var nextNodes = rendering.getNextNodes();
				
				for( var i = 0, n = array_length(nextNodes); i < n; i++ ) {
					var nextNode = nextNodes[i];
					if(!is(nextNode, __Node_Base) || !nextNode.isRenderable()) continue;
					
					// LOG_IF(global.FLAG.render == 1, $"→→ Push {nextNode.internalName} to queue.");
					RENDER_QUEUE.enqueue(nextNode);
					
					if(PROFILER_STAT) array_push(rendering.nextn, nextNode);
				}
				
				// if(runAction && rendering.hasInspector1Update()) rendering.inspector1Update();
					
				if(PROFILER_STAT) rendering.summarizeReport(render_pt);
				
			} else if(rendering.force_requeue)
				RENDER_QUEUE.enqueue(rendering);
			
			LOG_BLOCK_END();
		}
		
		_render_time /= 1000;
		
		LOG_IF(global.FLAG.renderTime || global.FLAG.render >= 1, $"=== RENDER FRAME {CURRENT_FRAME} COMPLETE IN {(get_timer() - t1) / 1000} ms ===\n");
		LOG_IF(global.FLAG.render >  1, $"=== RENDER SUMMARY STA ===");
		LOG_IF(global.FLAG.render >  1, $"  total time:  {(get_timer() - t1) / 1000} ms");
		LOG_IF(global.FLAG.render >  1, $"  leaf:        {_leaf_time / 1000} ms");
		LOG_IF(global.FLAG.render >  1, $"  render loop: {(get_timer() - t) / 1000} ms");
		LOG_IF(global.FLAG.render >  1, $"  render only: {_render_time} ms");
		LOG_IF(global.FLAG.render >  1, $"=== RENDER SUMMARY END ===");
		
	} catch(e) {
		noti_warning(exception_print(e));
	}
	
	// print("\n============== render stat ==============");
	// print($"Get value hit: {global.getvalue_hit}");
	
	LOG_END();
	
}

function __renderListReset(arr) {
	for( var i = 0; i < array_length(arr); i++ ) {
		arr[i].setRenderStatus(false);
		
		if(struct_has(arr[i], "nodes"))
			__renderListReset(arr[i].nodes);
	}
}

function RenderList(arr) {
	LOG_BLOCK_START();
	LOG_IF(global.FLAG.render == 1, $"=============== RENDER LIST START [{array_length(arr)}] ===============");
	var queue = ds_queue_create();
	
	try {
		var rendering = noone;
		var error	  = 0;
		var t		  = current_time;
		
		__renderListReset(arr);
		
		// get leaf node
		for( var i = 0, n = array_length(arr); i < n; i++ ) {
			var _node = arr[i];
			_node.passiveDynamic = false;
		}
		
		for( var i = 0, n = array_length(arr); i < n; i++ ) {
			var _node = arr[i];
			
			if(!__nodeIsRenderLeaf(_node))
				continue;
			
			LOG_IF(global.FLAG.render == 1, $"Found leaf {_node.internalName}");
			ds_queue_enqueue(queue, _node);
			_node.forwardPassiveDynamic();
		}
		
		LOG_IF(global.FLAG.render == 1, "Get leaf complete: found " + string(ds_queue_size(queue)) + " leaves.");
		LOG_IF(global.FLAG.render == 1, "=== Start rendering ===");
		
		// render forward
		while(!ds_queue_empty(queue)) {
			LOG_BLOCK_START();
			rendering = ds_queue_dequeue(queue)
			var renderable = rendering.isRenderable();
			
			LOG_IF(global.FLAG.render == 1, $"Rendering {rendering.internalName} ({rendering.display_name}) : {renderable? "Update" : "Pass"}");
			
			if(renderable) {
				rendering.doUpdate();
				
				var nextNodes = rendering.getNextNodes();
				for( var i = 0, n = array_length(nextNodes); i < n; i++ ) {
					var _node = nextNodes[i];
					if(array_exists(arr, _node) && _node.isRenderable())
						ds_queue_enqueue(queue, _node);
				}
			} 
			
			LOG_BLOCK_END();
		}
	
	} catch(e) {
		noti_warning(exception_print(e));
	}
	
	LOG_BLOCK_END();	
	LOG_IF(global.FLAG.render == 1, "=== RENDER COMPLETE ===\n");
	LOG_END();
	
	ds_queue_destroy(queue);
}