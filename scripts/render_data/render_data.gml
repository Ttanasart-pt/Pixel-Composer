enum RENDER_TYPE {
	none = 0,
	partial = 1,
	full = 2
}

#region globalvar
	globalvar UPDATE, RENDER_QUEUE, RENDER_ORDER, UPDATE_RENDER_ORDER;
	UPDATE_RENDER_ORDER    = false;
	global.FLAG.render     = 0;
	global.FLAG.renderTime = false;
	
	#macro RENDER_ALL_REORDER	UPDATE_RENDER_ORDER = true; UPDATE |= RENDER_TYPE.full;
	#macro RENDER_ALL									    UPDATE |= RENDER_TYPE.full;
	#macro RENDER_PARTIAL								    UPDATE |= RENDER_TYPE.partial;
#endregion

function __nodeLeafList(_list) { #region
	var nodes = [];
	var nodeNames = [];
	
	for( var i = 0, n = ds_list_size(_list); i < n; i++ ) {
		var _node = _list[| i];
		if(!_node.active) continue;
		if(!_node.isRenderActive()) continue;
		if(!_node.isLeaf()) continue;
		
		if(_node.isRenderable()) {
			array_push(nodes, _node);
			array_push(nodeNames, _node.internalName);
		}
	}
	
	LOG_LINE_IF(global.FLAG.render == 1, $"Push node {nodeNames} to queue");
	return nodes;
} #endregion

function ResetAllNodesRender() { #region
	LOG_IF(global.FLAG.render == 1, $"XXXXXXXXXXXXXXXXXXXX RESETTING ALL NODES [frame {CURRENT_FRAME}] XXXXXXXXXXXXXXXXXXXX");
	
	var _key = ds_map_find_first(PROJECT.nodeMap);
	var amo  = ds_map_size(PROJECT.nodeMap);
		
	repeat(amo) {
		var _node = PROJECT.nodeMap[? _key];
		_node.setRenderStatus(false);
		
		for( var i = 0, n = ds_list_size(_node.inputs); i < n; i++ ) 
			_node.inputs[| i].resetCache();
		
		_key = ds_map_find_next(PROJECT.nodeMap, _key);	
	}
} #endregion

function NodeTopoSort() { #region
	var _key = ds_map_find_first(PROJECT.nodeMap);
	var amo = ds_map_size(PROJECT.nodeMap);
		
	repeat(amo) {
		var _node = PROJECT.nodeMap[? _key];
		_node.topoSorted = false;
		_key = ds_map_find_next(PROJECT.nodeMap, _key);	
	}
	
	ds_list_clear(PROJECT.nodeTopo);
	__sortGraph(PROJECT.nodeTopo, PROJECT.nodes);
	
	LOG_IF(global.FLAG.render == 1, $"+++++++ Topo Sort Completed: {ds_list_size(PROJECT.nodeTopo)} nodes sorted +++++++");
} #endregion

function __sortGraph(_list, _nodeList) { #region
	var _root = [];
	
	for( var i = 0, n = ds_list_size(_nodeList); i < n; i++ ) {
		var _node = _nodeList[| i];
		var _isRoot = true;
		
		for( var j = 0, m = ds_list_size(_node.outputs); j < m; j++ ) {
			var _to = _node.outputs[| j].getJunctionTo();
			
			for( var k = 0, p = array_length(_to); k < p; k++ ) {
				if(ds_list_exist(_nodeList, _to[k].node)) {
					_isRoot = false;
					break;
				}
			}
			
			if(!_isRoot) break;
		}
		
		if(_isRoot) array_push(_root, _node);
	}
	
	var _st = ds_stack_create();
	
	for( var i = 0, n = array_length(_root); i < n; i++ ) 
		ds_stack_push(_st, _root[i]);
		
	while(!ds_stack_empty(_st)) {
		var _node = ds_stack_pop(_st);
		if(_node.topoSorted) continue;
		
		var _childs = [];
		
		for( var i = 0, n = ds_list_size(_node.inputs); i < n; i++ ) {
			var _in = _node.inputs[| i];
			var _fr = _in.value_from;
			
			if(_fr == noone)						continue;
			if(!ds_list_exist(_nodeList, _fr.node)) continue;
			if(_fr.node.topoSorted)					continue;
			
			array_push(_childs, _fr.node);
		}
		
		if(array_empty(_childs)) {
			ds_list_add(_list, _node);
			_node.topoSorted = true;
			
			if(is_instanceof(_node, Node_Collection) && !_node.managedRenderOrder)
				__sortGraph(_list, _node.nodes);
		} else {
			ds_stack_push(_st, _node);
			for( var i = 0, n = array_length(_childs); i < n; i++ ) 
				ds_stack_push(_st, _childs[i]);
		}
	}
} #endregion

function NodeListSort(_list, _nodeList) { #region
	for( var i = 0, n = ds_list_size(_nodeList); i < n; i++ )
		_nodeList[| i].topoSorted = false;
	
	ds_list_clear(_list);
	__sortGraph(_list, _nodeList);
} #endregion

function __nodeIsRenderLeaf(_node) { #region
	if(is_undefined(_node))									 { LOG_IF(global.FLAG.render == 1, $"Skip undefiend		  [{_node}]"); return false; }
	if(!is_instanceof(_node, Node))							 { LOG_IF(global.FLAG.render == 1, $"Skip non-node		  [{_node}]"); return false; }
			
	if(_node.is_group_io)									 { LOG_IF(global.FLAG.render == 1, $"Skip group IO		  [{_node.internalName}]"); return false; }
			
	if(!_node.active)										 { LOG_IF(global.FLAG.render == 1, $"Skip inactive         [{_node.internalName}]"); return false; }
	if(!_node.isRenderActive())								 { LOG_IF(global.FLAG.render == 1, $"Skip render inactive  [{_node.internalName}]"); return false; }
	if(!_node.attributes.update_graph)						 { LOG_IF(global.FLAG.render == 1, $"Skip non-auto update  [{_node.internalName}]"); return false; }
			
	if(_node.passiveDynamic) { _node.forwardPassiveDynamic();  LOG_IF(global.FLAG.render == 1, $"Skip passive dynamic  [{_node.internalName}]"); return false; }
	
	if(!_node.isActiveDynamic())							 { LOG_IF(global.FLAG.render == 1, $"Skip rendered static  [{_node.internalName}]"); return false; }
	for( var i = 0, n = array_length(_node.context_data); i < n; i++ ) 
		if(_node.context_data[i].managedRenderOrder) return false;
	
	return true;
} #endregion

function Render(partial = false, runAction = false) { #region
	LOG_BLOCK_START();
	LOG_IF(global.FLAG.render, $"============================== RENDER START [{partial? "PARTIAL" : "FULL"}] [frame {CURRENT_FRAME}] ==============================");
	
	try {
		var t  = get_timer();
		var t1 = get_timer();
		
		var _render_time = 0;
		var _leaf_time   = 0;
		
		var rendering = noone;
		var error     = 0;
		var reset_all = !partial;
		
		if(reset_all) {
			var _key = ds_map_find_first(PROJECT.nodeMap);
			var amo = ds_map_size(PROJECT.nodeMap);
		
			repeat(amo) {
				var _node = PROJECT.nodeMap[? _key];
				_node.setRenderStatus(false);
				_key = ds_map_find_next(PROJECT.nodeMap, _key);	
			}
		}
		
		// get leaf node
		LOG_IF(global.FLAG.render == 1, $"----- Finding leaf from {ds_list_size(PROJECT.nodeTopo)} nodes -----");
		RENDER_QUEUE.clear();
		for( var i = 0, n = ds_list_size(PROJECT.nodeTopo); i < n; i++ ) {
			var _node = PROJECT.nodeTopo[| i];
			_node.passiveDynamic = false;
		}
		
		for( var i = 0, n = ds_list_size(PROJECT.nodeTopo); i < n; i++ ) {
			var _node = PROJECT.nodeTopo[| i];
			_node.render_time = 0;
			
			if(!__nodeIsRenderLeaf(_node))
				continue;
			
			LOG_IF(global.FLAG.render == 1, $"    Found leaf [{_node.internalName}]");
			RENDER_QUEUE.enqueue(_node);
			_node.forwardPassiveDynamic();
		}
		
		_leaf_time = get_timer() - t;
		LOG_IF(global.FLAG.render >= 1, $"Get leaf complete: found {RENDER_QUEUE.size()} leaves in {(get_timer() - t) / 1000} ms."); t = get_timer();
		LOG_IF(global.FLAG.render == 1,  "================== Start rendering ==================");
		
		// render forward
		while(!RENDER_QUEUE.empty()) {
			LOG_BLOCK_START();
			LOG_IF(global.FLAG.render == 1, $"➤➤➤➤➤➤ CURRENT RENDER QUEUE {RENDER_QUEUE} [{RENDER_QUEUE.size()}] ");
			
			rendering = RENDER_QUEUE.dequeue();
			var renderable = rendering.isRenderable();
			
			LOG_IF(global.FLAG.render == 1, $"Rendering {rendering.internalName} ({rendering.display_name}) : {renderable? "Update" : "Pass"} ({rendering.rendered})");
			
			if(renderable) {
				var _render_pt = get_timer();
				rendering.doUpdate();
				_render_time += get_timer() - _render_pt;
				
				var nextNodes = rendering.getNextNodes();
				for( var i = 0, n = array_length(nextNodes); i < n; i++ ) {
					if(nextNodes[i].isRenderable())
						RENDER_QUEUE.enqueue(nextNodes[i]);
				}
				
				if(runAction && rendering.hasInspector1Update())
					rendering.inspector1Update();
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
	
	LOG_END();
} #endregion

function __renderListReset(list) { #region
	for( var i = 0; i < ds_list_size(list); i++ ) {
		list[| i].setRenderStatus(false);
		
		if(struct_has(list[| i], "nodes"))
			__renderListReset(list[| i].nodes);
	}
} #endregion

function RenderList(list) { #region
	LOG_BLOCK_START();
	LOG_IF(global.FLAG.render == 1, $"=============== RENDER LIST START [{ds_list_size(list)}] ===============");
	var queue = ds_queue_create();
	
	try {
		var rendering = noone;
		var error	  = 0;
		var t		  = current_time;
		
		__renderListReset(list);
		
		// get leaf node
		for( var i = 0, n = ds_list_size(list); i < n; i++ ) {
			var _node = list[| i];
			_node.passiveDynamic = false;
		}
		
		for( var i = 0, n = ds_list_size(list); i < n; i++ ) {
			var _node = list[| i];
			
			if(!__nodeIsRenderLeaf(_node))
				continue;
			
			LOG_IF(global.FLAG.render == 1, $"Found leaf {_node.internalName}");
			ds_queue_enqueue(queue, _node);
			_node.forwardPassiveDynamic();
			
			LOG_BLOCK_END();
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
					if(ds_list_exist(list, _node) && _node.isRenderable())
						ds_queue_enqueue(queue, _node);
				}
			} 
			
			LOG_BLOCK_END();
		}
	
	} catch(e) {
		noti_warning(exception_print(e));
	}
		
	LOG_IF(global.FLAG.render == 1, "=== RENDER COMPLETE ===\n");
	LOG_END();
	
	ds_queue_destroy(queue);
} #endregion