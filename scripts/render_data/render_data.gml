enum RENDER_TYPE {
	none = 0,
	partial = 1,
	full = 2
}

#region globalvar
	global.DEBUG_FLAG.render = false;
	global.group_inputs = [ "Node_Group_Input", "Node_Feedback_Input", "Node_Iterator_Input", "Node_Iterator_Each_Input" ];
#endregion

function __nodeLeafList(_list) {
	var nodes = [];
	LOG_BLOCK_START();
	
	for( var i = 0; i < ds_list_size(_list); i++ ) {
		var _node = _list[| i];
		if(!_node.active) continue;
		if(!_node.renderActive) continue;
		
		var _startNode = _node.isRenderable();
		if(_startNode) {
			array_push(nodes, _node);
			LOG_IF(global.DEBUG_FLAG.render, "Push node " + _node.name + " to stack");
		}
	}
	
	LOG_BLOCK_END();
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
	LOG_IF(global.DEBUG_FLAG.render, "=== RENDER START [frame " + string(ANIMATOR.current_frame) + "] ===");
	
	try {
		var rendering = noone;
		var error = 0;
		
		if(!partial || ALWAYS_FULL) {
			var _key = ds_map_find_first(NODE_MAP);
			var amo = ds_map_size(NODE_MAP);
		
			repeat(amo) {
				var _node = NODE_MAP[? _key];
				_node.setRenderStatus(false);
				_key = ds_map_find_next(NODE_MAP, _key);	
			}
		}
	
		// get leaf node
		ds_queue_clear(RENDER_QUEUE);
		var key = ds_map_find_first(NODE_MAP);
		var amo = ds_map_size(NODE_MAP);
		repeat(amo) {
			var _node = NODE_MAP[? key];
			key = ds_map_find_next(NODE_MAP, key);
		
			if(is_undefined(_node)) continue;
			if(!is_struct(_node))	continue;
			if(array_exists(global.group_inputs, instanceof(_node))) continue;
			
			if(!_node.active)		continue;
			if(!_node.renderActive) continue;
			if(_node.rendered) {
				LOG_IF(global.DEBUG_FLAG.render, "Skip rendered " + _node.name + " (" + _node.display_name + ")");
				continue;
			}
			
			if(__nodeInLoop(_node)) continue;
			
			LOG_BLOCK_START();
			
			var _startNode = _node.isRenderable(global.DEBUG_FLAG.render);
			if(_startNode) {
				LOG_IF(global.DEBUG_FLAG.render, "Found leaf " + _node.name + " (" + _node.display_name + ")");
				
				_node.triggerRender();
				ds_queue_enqueue(RENDER_QUEUE, _node);
			} else 
				LOG_IF(global.DEBUG_FLAG.render, "Skip non-leaf " + _node.name + " (" + _node.display_name + ")");
			
			LOG_BLOCK_END();
		}
		
		LOG_IF(global.DEBUG_FLAG.render, "Get leaf complete: found " + string(ds_queue_size(RENDER_QUEUE)) + " leaves.");
		LOG_IF(global.DEBUG_FLAG.render, "Start rendering...");
	
		// render forward
		while(!ds_queue_empty(RENDER_QUEUE)) {
			rendering = ds_queue_dequeue(RENDER_QUEUE);
			var renderable = rendering.isRenderable();
			
			LOG_BLOCK_START();
			LOG_IF(global.DEBUG_FLAG.render, "Rendering " + rendering.name + " (" + rendering.display_name + ") ");
			
			if(renderable) {
				rendering.doUpdate();
				
				var nextNodes = rendering.getNextNodes();
				for( var i = 0; i < array_length(nextNodes); i++ )
					ds_queue_enqueue(RENDER_QUEUE, nextNodes[i]);
				
				if(runAction && rendering.hasInspector1Update())
					rendering.inspector1Update();
			}
			
			LOG_IF(global.DEBUG_FLAG.render, "Rendered " + rendering.name + " (" + rendering.display_name + ") [" + string(instanceof(rendering)) + "]" + (renderable? " [Update]" : " [Skip]"));
			LOG_BLOCK_END();
		}
	} catch(e) {
		noti_warning(exception_print(e));
	}
	
	LOG_IF(global.DEBUG_FLAG.render, "=== RENDER COMPLETE IN {" + string(current_time - t) + "ms} ===\n");
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
	LOG_IF(global.DEBUG_FLAG.render, "=== RENDER LIST START ===");
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
			if(!is_struct(_node))	continue;
			
			if(!_node.active)		continue;
			if(!_node.renderActive) continue;
			if(_node.rendered)		continue;
		
			if(_node.isRenderable())
				ds_queue_enqueue(queue, _node);
		}
		
		LOG_IF(global.DEBUG_FLAG.render, "Get leaf complete: found " + string(ds_queue_size(queue)) + " leaves.");
		LOG_IF(global.DEBUG_FLAG.render, "Start rendering...");
		
		// render forward
		while(!ds_queue_empty(queue)) {
			rendering = ds_queue_dequeue(queue);
			if(!rendering.isRenderable()) continue;
			
			rendering.doUpdate();
				
			LOG_LINE_IF(global.DEBUG_FLAG.render, "Rendering " + rendering.name + " (" + rendering.display_name + ") ");
				
			var nextNodes = rendering.getNextNodes();
			for( var i = 0; i < array_length(nextNodes); i++ ) 
				ds_queue_enqueue(queue, nextNodes[i]);
		}
	
	} catch(e) {
		noti_warning(exception_print(e));
	}
		
	LOG_IF(global.DEBUG_FLAG.render, "=== RENDER COMPLETE ===\n");
	LOG_END();
	
	ds_queue_destroy(queue);
}

function RenderListAction(list, context = PANEL_GRAPH.getCurrentContext()) {
	printIf(global.DEBUG_FLAG.render, "=== RENDER LIST ACTION START [frame " + string(ANIMATOR.current_frame) + "] ===");
	
	try {
		var rendering = noone;
		var error	  = 0;
		var t		  = current_time;
		
		__renderListReset(list);
		
		// get leaf node
		ds_queue_clear(RENDER_QUEUE);
		for( var i = 0; i < ds_list_size(list); i++ ) {
			var _node = list[| i];
			
			if(is_undefined(_node)) continue;
			if(!is_struct(_node))	continue;
			
			if(!_node.active)		continue;
			if(!_node.renderActive) continue;
			if(_node.rendered)		continue;
		
			if(_node.isRenderable()) {
				ds_queue_enqueue(RENDER_QUEUE, _node);
				printIf(global.DEBUG_FLAG.render, "		> Push " + _node.name + " (" + _node.display_name + ") node to stack");
			}
		}
		
		// render forward
		while(!ds_queue_empty(RENDER_QUEUE)) {
			rendering = ds_queue_dequeue(RENDER_QUEUE);
			if(rendering.group == context) break;
			
			var txt = rendering.isRenderable()? " [Skip]" : " [Update]";
			
			if(!rendering.isRenderable()) {
				rendering.doUpdate();
				if(rendering.hasInspector1Update()) {
					rendering.inspector1Update();
					printIf(global.DEBUG_FLAG.render, " > Toggle manual execution " + rendering.name + " (" + rendering.display_name + ")");
				}
				
				var nextNodes = rendering.getNextNodes();
				for( var i = 0; i < array_length(nextNodes); i++ ) 
					ds_queue_enqueue(RENDER_QUEUE, nextNodes[i]);
			}
			
			printIf(global.DEBUG_FLAG.render, "Rendered " + rendering.name + " (" + rendering.display_name + ") [" + string(instanceof(rendering)) + "]" + txt);
		}
	
		printIf(global.DEBUG_FLAG.render, "=== RENDER COMPLETE IN {" + string(current_time - t) + "ms} ===\n");
	} catch(e) {
		noti_waning(exception_print(e));
	}
}