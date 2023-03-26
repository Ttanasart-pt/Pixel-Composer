enum RENDER_TYPE {
	none = 0,
	partial = 1,
	full = 2
}

global.RENDER_LOG	= false;
global.group_inputs = [ "Node_Group_Input", "Node_Feedback_Input", "Node_Iterator_Input", "Node_Iterator_Each_Input" ];

function __nodeLeafList(_list, _queue) {
	for( var i = 0; i < ds_list_size(_list); i++ ) {
		var _node = _list[| i];
		if(!_node.active) continue;
		if(!_node.renderActive) continue;
		
		_node.triggerRender();
		var _startNode = _node.isRenderable();
		if(_startNode) {
			ds_queue_enqueue(_queue, _node);
			printIf(global.RENDER_LOG, "Push node " + _node.name + " to stack");
		}
	}
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
	try {
		var rendering = noone;
		var error = 0;
		var t = current_time;
		printIf(global.RENDER_LOG, "=== RENDER START [frame " + string(ANIMATOR.current_frame) + "] ===");
	
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
			if(_node.rendered)		continue;
			if(__nodeInLoop(_node)) continue;
		
			var _startNode = _node.isRenderable();
			printIf(global.RENDER_LOG, "    > Check leaf " + _node.name + " (" + _node.display_name + "): " + string(_startNode));
			
			if(_startNode)
				ds_queue_enqueue(RENDER_QUEUE, _node);
		}
	
		// render forward
		while(!ds_queue_empty(RENDER_QUEUE)) {
			rendering = ds_queue_dequeue(RENDER_QUEUE);
		
			if(!rendering.rendered) {
				rendering.doUpdate();
				rendering.setRenderStatus(true);
				printIf(global.RENDER_LOG, "Rendered " + rendering.name + " (" + rendering.display_name + ") [" + string(instanceof(rendering)) + "] (Update)");
				
				rendering.getNextNodes();
				
				if(runAction && rendering.hasInspectorUpdate())
					rendering.inspectorUpdate();
			} else 
				printIf(global.RENDER_LOG, "Rendered " + rendering.name + " (" + rendering.display_name + ") [" + string(instanceof(rendering)) + "] (Skip)");
		}
	
		printIf(global.RENDER_LOG, "=== RENDER COMPLETE IN {" + string(current_time - t) + "ms} ===\n");
	} catch(e)
		noti_warning(exception_print(e));
}

function __renderListReset(list) {
	for( var i = 0; i < ds_list_size(list); i++ ) {
		list[| i].setRenderStatus(false);
		
		if(struct_has(list[| i], "nodes"))
			__renderListReset(list[| i].nodes);
	}
}

function RenderListAction(list, context = PANEL_GRAPH.getCurrentContext()) {
	printIf(global.RENDER_LOG, "=== RENDER LIST ACTION START [frame " + string(ANIMATOR.current_frame) + "] ===");
	
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
				printIf(global.RENDER_LOG, "    > Push " + _node.name + " (" + _node.display_name + ") node to stack");
			}
		}
		
		// render forward
		while(!ds_queue_empty(RENDER_QUEUE)) {
			rendering = ds_queue_dequeue(RENDER_QUEUE);
			if(rendering.group == context) break;
			
			var txt = rendering.rendered? " [Skip]" : " [Update]";
			if(!rendering.rendered) {
				rendering.doUpdate();
				if(rendering.hasInspectorUpdate()) {
					rendering.inspectorUpdate();
					printIf(global.RENDER_LOG, " > Toggle manual execution " + rendering.name + " (" + rendering.display_name + ")");
				}
					
				rendering.setRenderStatus(true);
				rendering.getNextNodes();
			}
			printIf(global.RENDER_LOG, "Rendered " + rendering.name + " (" + rendering.display_name + ") [" + string(instanceof(rendering)) + "]" + txt);
		}
	
		printIf(global.RENDER_LOG, "=== RENDER COMPLETE IN {" + string(current_time - t) + "ms} ===\n");
	} catch(e)
		noti_warning(exception_print(e));
}