enum RENDER_TYPE {
	none = 0,
	partial = 1,
	full = 2
}

#region globalvar
	globalvar UPDATE, RENDER_QUEUE, RENDER_ORDER, UPDATE_RENDER_ORDER;
	UPDATE_RENDER_ORDER = false;
	global.FLAG.render  = 1;
	global.group_io = [ 
		"Node_Group_Input",				"Node_Group_Output", 
		"Node_Feedback_Input", 			"Node_Feedback_Output", 
		"Node_Iterator_Input", 			"Node_Iterator_Output", 
		"Node_Iterator_Each_Input", 	"Node_Iterator_Each_Output", 
		"Node_Iterator_Filter_Input", 	"Node_Iterator_Filter_Output",
	];
	
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
		
		var _startNode = _node.isRenderable();
		if(_startNode) {
			array_push(nodes, _node);
			array_push(nodeNames, _node.internalName);
		}
	}
	
	LOG_LINE_IF(global.FLAG.render == 1, $"Push node {nodeNames} to queue");
	return nodes;
} #endregion

function __nodeIsLoop(_node) { #region
	switch(instanceof(_node)) {
		case "Node_Iterate" : 
		case "Node_Iterate_Each" : 
		case "Node_Iterate_Filter" : 
		case "Node_Iterate_Sort" : 
			return true;
	}
	return false;
} #endregion

function __nodeInLoop(_node) { #region
	var gr = _node.group;
	while(gr != noone) {
		if(__nodeIsLoop(gr)) return true;
		gr = gr.group;
	}
	return false;
} #endregion

function ResetAllNodesRender() { #region
	LOG_IF(global.FLAG.render == 1, $"XXXXXXXXXXXXXXXXXXXX RESETTING ALL NODES [frame {PROJECT.animator.current_frame}] XXXXXXXXXXXXXXXXXXXX");
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

function Render(partial = false, runAction = false) { #region
	LOG_BLOCK_START();
	LOG_IF(global.FLAG.render, $"============================== RENDER START [{partial? "PARTIAL" : "FULL"}] [frame {PROJECT.animator.current_frame}] ==============================");
	
	try {
		var t  = get_timer();
		var t1 = get_timer();
		
		var _render_time = 0;
		var _leaf_time   = 0;
		
		var rendering = noone;
		var error     = 0;
		var reset_all = !partial || ALWAYS_FULL;
		
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
		RENDER_QUEUE.clear();
		var key = ds_map_find_first(PROJECT.nodeMap);
		var amo = ds_map_size(PROJECT.nodeMap);
		repeat(amo) {
			var _node = PROJECT.nodeMap[? key];
			key = ds_map_find_next(PROJECT.nodeMap, key);
			
			if(is_undefined(_node)) { LOG_IF(global.FLAG.render == 1, $"Skip undefiend   {_node}"); continue; }
			if(!is_struct(_node))	{ LOG_IF(global.FLAG.render == 1, $"Skip non-struct  {_node}"); continue; }
			if(array_exists(global.group_io, instanceof(_node))) {
				LOG_IF(global.FLAG.render == 1, $"Skip group IO {_node.internalName}");
				continue;
			}
			
			_node.render_time = 0;
			
			if(!_node.active)			{ LOG_IF(global.FLAG.render == 1, $"Skip inactive          {_node.internalName}"); continue; }
			if(!_node.isRenderActive()) { LOG_IF(global.FLAG.render == 1, $"Skip non-renderActive  {_node.internalName}"); continue; }
			if(!_node.attributes.update_graph) { LOG_IF(global.FLAG.render == 1, $"Skip non-auto update {_node.internalName}"); continue; }
			
			if(_node.rendered && !_node.isAnimated()) {
				_node.anim_last_step = false;
				LOG_IF(global.FLAG.render == 1, $"Skip rendered {_node.internalName}");
				continue;
			}
			
			if(__nodeInLoop(_node)) { LOG_IF(global.FLAG.render == 1, $"Skip in-loop {_node.internalName}"); continue; }
			
			LOG_BLOCK_START();
			
			var _startNode = _node.isRenderable(global.FLAG.render);
			if(_startNode) {
				LOG_IF(global.FLAG.render == 1, $"Found leaf {_node.internalName}");
				//if(!reset_all) _node.resetRenderForward();
				RENDER_QUEUE.enqueue(_node);
			} else 
				LOG_IF(global.FLAG.render == 1, $"Skip non-leaf {_node.internalName}");
			
			LOG_BLOCK_END();
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
			
			LOG_IF(global.FLAG.render == 1, $"Rendering {rendering.internalName} ({rendering.display_name}) : {renderable? "Update" : "Pass"}");
			
			if(renderable) {
				var _render_pt = get_timer();
				rendering.doUpdate();
				_render_time += get_timer() - _render_pt;
				
				var nextNodes = rendering.getNextNodes();
				for( var i = 0, n = array_length(nextNodes); i < n; i++ ) {
					RENDER_QUEUE.enqueue(nextNodes[i]);
				}
				
				if(runAction && rendering.hasInspector1Update())
					rendering.inspector1Update();
			}
			
			LOG_BLOCK_END();
		}
		
		_render_time /= 1000;
		
		LOG_IF(global.FLAG.render >= 1, $"=== RENDER COMPLETE IN {(get_timer() - t1) / 1000} ms ===\n");
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
	LOG_IF(global.FLAG.render == 1, "=============== RENDER LIST START ===============");
	var queue = ds_queue_create();
	
	try {
		var rendering = noone;
		var error	  = 0;
		var t		  = current_time;
		
		__renderListReset(list);
		
		// get leaf node
		for( var i = 0; i < ds_list_size(list); i++ ) {
			var _node = list[| i];
			
			if(is_undefined(_node)) continue;
			if(!is_struct(_node)) continue;
			
			if(!_node.active) continue;
			if(!_node.isRenderActive()) continue;
			if(_node.rendered) continue;
		
			if(_node.isRenderable())
				ds_queue_enqueue(queue, _node);
		}
		
		LOG_IF(global.FLAG.render == 1, "Get leaf complete: found " + string(ds_queue_size(queue)) + " leaves.");
		LOG_IF(global.FLAG.render == 1, "=== Start rendering ===");
		
		// render forward
		while(!ds_queue_empty(queue)) {
			LOG_BLOCK_START();
			LOG_IF(global.FLAG.render == 1, $"➤➤➤➤➤➤ CURRENT RENDER QUEUE {RENDER_QUEUE}");
			rendering = RENDER_QUEUE.dequeue();
			if(!ds_list_exist(list, rendering)) continue;
			var renderable = rendering.isRenderable();
			
			LOG_IF(global.FLAG.render == 1, $"Rendering {rendering.internalName} ({rendering.display_name}) : {renderable? "Update" : "Pass"}");
			
			if(renderable) {
				rendering.doUpdate();
				
				var nextNodes = rendering.getNextNodes();
				for( var i = 0, n = array_length(nextNodes); i < n; i++ )
					RENDER_QUEUE.enqueue(nextNodes[i]);
				
				if(runAction && rendering.hasInspector1Update())
					rendering.inspector1Update();
			} else if(rendering.isRenderActive()) {
				RENDER_QUEUE.enqueue(rendering);
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

function RenderListAction(list, context = PANEL_GRAPH.getCurrentContext()) { #region
	printIf(global.FLAG.render, "=== RENDER LIST ACTION START [frame " + string(PROJECT.animator.current_frame) + "] ===");
	
	try {
		var rendering = noone;
		var error	  = 0;
		var t		  = current_time;
		
		__renderListReset(list);
		
		// get leaf node
		RENDER_QUEUE.clear();
		for( var i = 0; i < ds_list_size(list); i++ ) {
			var _node = list[| i];
			
			if(is_undefined(_node)) continue;
			if(!is_struct(_node)) continue;
			
			if(!_node.active) continue;
			if(!_node.isRenderActive()) continue;
			if(_node.rendered) continue;
		
			if(_node.isRenderable()) {
				RENDER_QUEUE.enqueue(_node);
				printIf(global.FLAG.render, $"		> Push {_node.internalName} node to queue");
			}
		}
		
		// render forward
		while(!RENDER_QUEUE.empty()) {
			LOG_BLOCK_START();
			LOG_IF(global.FLAG.render == 1, $"➤➤➤➤➤➤ CURRENT RENDER QUEUE {RENDER_QUEUE}");
			rendering = RENDER_QUEUE.dequeue();
			if(!ds_list_exist(list, rendering)) continue;
			var renderable = rendering.isRenderable();
			
			LOG_IF(global.FLAG.render == 1, $"Rendering {rendering.internalName} ({rendering.display_name}) : {renderable? "Update" : "Pass"}");
			
			if(renderable) {
				rendering.doUpdate();
				
				var nextNodes = rendering.getNextNodes();
				for( var i = 0, n = array_length(nextNodes); i < n; i++ )
					RENDER_QUEUE.enqueue(nextNodes[i]);
				
				if(runAction && rendering.hasInspector1Update())
					rendering.inspector1Update();
			} else if(rendering.isRenderActive()) {
				RENDER_QUEUE.enqueue(rendering);
			}
			
			LOG_BLOCK_END();
		}
	
		printIf(global.FLAG.render, "=== RENDER COMPLETE IN {" + string(current_time - t) + "ms} ===\n");
	} catch(e) {
		noti_warning(exception_print(e));
	}
} #endregion