enum RENDER_TYPE {
	none = 0,
	partial = 1,
	full = 2
}

#region globalvar
	global.FLAG.render  = false;
	global.group_inputs = [ "Node_Group_Input", "Node_Feedback_Input", "Node_Iterator_Input", "Node_Iterator_Each_Input" ];
#endregion

function __nodeLeafList(_list) {
	var nodes = [];
	var nodeNames = [];
	
	for( var i = 0; i < ds_list_size(_list); i++ ) {
		var _node = _list[| i];
		if(!_node.active) continue;
		if(!_node.isRenderActive()) continue;
		
		var _startNode = _node.isRenderable();
		if(_startNode) {
			array_push(nodes, _node);
			array_push(nodeNames, _node.internalName);
		}
	}
	
	LOG_LINE_IF(global.FLAG.render, $"Push node {nodeNames} to stack");
	return nodes;
}

function __nodeIsLoop(_node) {
	switch(instanceof(_node)) {
		case "Node_Iterate" : 
		case "Node_Iterate_Each" : 
		case "Node_Iterate_Filter" : 
		case "Node_Feedback" :
			return true;
	}
	return false;
}

function __nodeInLoop(_node) {
	var gr = _node.group;
	while(gr != noone) {
		if(__nodeIsLoop(gr)) return true;
		gr = gr.group;
	}
	return false;
}

function Render(partial = false, runAction = false) { 
	var t = current_time;
	LOG_BLOCK_START();
	LOG_IF(global.FLAG.render, 
$"============================== RENDER START [frame {string(PROJECT.animator.current_frame)}] ==============================");
	
	try {
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
		
			if(is_undefined(_node)) continue;
			if(!is_struct(_node)) continue;
			if(array_exists(global.group_inputs, instanceof(_node))) continue;
			
			if(!_node.active) continue;
			if(!_node.isRenderActive()) continue;
			if(_node.rendered) {
				LOG_IF(global.FLAG.render, $"Skip rendered {_node.internalName}");
				continue;
			}
			
			//if(__nodeInLoop(_node)) continue;
			if(_node.group != noone) continue;
			
			LOG_BLOCK_START();
			
			var _startNode = _node.isRenderable(global.FLAG.render);
			if(_startNode) {
				LOG_IF(global.FLAG.render, $"Found leaf {_node.internalName}");
				
				if(!reset_all) _node.triggerRender();
				RENDER_QUEUE.enqueue(_node);
			} else 
				LOG_IF(global.FLAG.render, $"Skip non-leaf {_node.internalName}");
			
			LOG_BLOCK_END();
		}
		
		LOG_IF(global.FLAG.render, $"Get leaf complete: found {RENDER_QUEUE.size()} leaves.");
		LOG_IF(global.FLAG.render,  "================== Start rendering ==================");
	
		// render forward
		while(!RENDER_QUEUE.empty()) {
			LOG_BLOCK_START();
			LOG_IF(global.FLAG.render, $"➤➤➤➤➤➤ CURRENT RENDER QUEUE {RENDER_QUEUE}");
			rendering = RENDER_QUEUE.dequeue();
			var renderable = rendering.isRenderable();
			
			LOG_IF(global.FLAG.render, $"Rendering {rendering.internalName} ({rendering.display_name}) : {renderable? "Update" : "Pass"}");
			
			if(renderable) {
				rendering.doUpdate();
				
				var nextNodes = rendering.getNextNodes();
				for( var i = 0; i < array_length(nextNodes); i++ )
					RENDER_QUEUE.enqueue(nextNodes[i]);
				
				if(runAction && rendering.hasInspector1Update())
					rendering.inspector1Update();
			}
			
			LOG_BLOCK_END();
		}
	} catch(e) {
		noti_warning(exception_print(e));
	}
	
	LOG_IF(global.FLAG.render, "=== RENDER COMPLETE IN {" + string(current_time - t) + "ms} ===\n");
	LOG_END();
}

function __renderListReset(list) {
	for( var i = 0; i < ds_list_size(list); i++ ) {
		list[| i].setRenderStatus(false);
		
		if(struct_has(list[| i], "nodes"))
			__renderListReset(list[| i].nodes);
	}
}

function RenderList(list) {
	LOG_BLOCK_START();
	LOG_IF(global.FLAG.render, "=============== RENDER LIST START ===============");
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
		
		LOG_IF(global.FLAG.render, "Get leaf complete: found " + string(ds_queue_size(queue)) + " leaves.");
		LOG_IF(global.FLAG.render, "=== Start rendering ===");
		
		// render forward
		while(!ds_queue_empty(queue)) {
			LOG_BLOCK_START();
			LOG_IF(global.FLAG.render, $"➤➤➤➤➤➤ CURRENT RENDER QUEUE {RENDER_QUEUE}");
			rendering = RENDER_QUEUE.dequeue();
			if(!ds_list_exist(list, rendering)) continue;
			var renderable = rendering.isRenderable();
			
			LOG_IF(global.FLAG.render, $"Rendering {rendering.internalName} ({rendering.display_name}) : {renderable? "Update" : "Pass"}");
			
			if(renderable) {
				rendering.doUpdate();
				
				var nextNodes = rendering.getNextNodes();
				for( var i = 0; i < array_length(nextNodes); i++ )
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
		
	LOG_IF(global.FLAG.render, "=== RENDER COMPLETE ===\n");
	LOG_END();
	
	ds_queue_destroy(queue);
}

function RenderListAction(list, context = PANEL_GRAPH.getCurrentContext()) {
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
				printIf(global.FLAG.render, $"		> Push {_node.internalName} node to stack");
			}
		}
		
		// render forward
		while(!RENDER_QUEUE.empty()) {
			LOG_BLOCK_START();
			LOG_IF(global.FLAG.render, $"➤➤➤➤➤➤ CURRENT RENDER QUEUE {RENDER_QUEUE}");
			rendering = RENDER_QUEUE.dequeue();
			if(!ds_list_exist(list, rendering)) continue;
			var renderable = rendering.isRenderable();
			
			LOG_IF(global.FLAG.render, $"Rendering {rendering.internalName} ({rendering.display_name}) : {renderable? "Update" : "Pass"}");
			
			if(renderable) {
				rendering.doUpdate();
				
				var nextNodes = rendering.getNextNodes();
				for( var i = 0; i < array_length(nextNodes); i++ )
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
		noti_waning(exception_print(e));
	}
}