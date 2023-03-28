enum RENDER_TYPE {
	none = 0,
	partial = 1,
	full = 2
}

#region globalvar
	global.RENDER_DEBUG = false;
	
	global.RENDER_LOG	= false;
	global.group_inputs = [ "Node_Group_Input", "Node_Feedback_Input", "Node_Iterator_Input", "Node_Iterator_Each_Input" ];
#endregion

function __nodeLeafList(_list) {
	var nodes = [];
	
	for( var i = 0; i < ds_list_size(_list); i++ ) {
		var _node = _list[| i];
		if(!_node.active) continue;
		if(!_node.renderActive) continue;
		
		_node.triggerRender();
		var _startNode = _node.isRenderable();
		if(_startNode) {
			array_push(nodes, _node);
			printIf(global.RENDER_LOG, "Push node " + _node.name + " to stack");
		}
	}
	
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
	printIf(global.RENDER_LOG, "=== RENDER START [frame " + string(ANIMATOR.current_frame) + "] ===");
	
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
			if(_node.rendered)		continue;
			if(__nodeInLoop(_node)) continue;
		
			var _startNode = _node.isRenderable();
			if(_startNode) {
				printIf(global.RENDER_LOG, "    > Found leaf " + _node.name + " (" + _node.display_name + ")");
				
				_node.triggerRender();
				ds_queue_enqueue(RENDER_QUEUE, _node);
			}
		}
	
		// render forward
		while(!ds_queue_empty(RENDER_QUEUE)) {
			rendering = ds_queue_dequeue(RENDER_QUEUE);
		
			if(!rendering.rendered) {
				rendering.doUpdate();
				printIf(global.RENDER_LOG, "Rendered " + rendering.name + " (" + rendering.display_name + ") [" + string(instanceof(rendering)) + "] (Update)");
				
				var nextNodes = rendering.getNextNodes();
				for( var i = 0; i < array_length(nextNodes); i++ ) {
					if(!nextNodes[i].isRenderable()) continue;
					ds_queue_enqueue(RENDER_QUEUE, nextNodes[i]);
				}
				
				if(runAction && rendering.hasInspector1Update())
					rendering.inspector1Update();
			} else 
				printIf(global.RENDER_LOG, "Rendered " + rendering.name + " (" + rendering.display_name + ") [" + string(instanceof(rendering)) + "] (Skip)");
		}
	} catch(e)
		noti_warning(exception_print(e));
	
	printIf(global.RENDER_LOG, "=== RENDER COMPLETE IN {" + string(current_time - t) + "ms} ===\n");
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
				if(rendering.hasInspector1Update()) {
					rendering.inspector1Update();
					printIf(global.RENDER_LOG, " > Toggle manual execution " + rendering.name + " (" + rendering.display_name + ")");
				}
				
				var nextNodes = rendering.getNextNodes();
				for( var i = 0; i < array_length(nextNodes); i++ ) {
					if(!nextNodes[i].isRenderable()) continue;
					ds_queue_enqueue(RENDER_QUEUE, nextNodes[i]);
				}
			}
			printIf(global.RENDER_LOG, "Rendered " + rendering.name + " (" + rendering.display_name + ") [" + string(instanceof(rendering)) + "]" + txt);
		}
	
		printIf(global.RENDER_LOG, "=== RENDER COMPLETE IN {" + string(current_time - t) + "ms} ===\n");
	} catch(e)
		noti_warning(exception_print(e));
}