enum RENDER_TYPE {
	none = 0,
	partial = 1,
	full = 2
}

global.RENDER_LOG = true;

function __nodeLeafList(_list, _queue) {
	for( var i = 0; i < ds_list_size(_list); i++ ) {
		var _node = _list[| i];
		if(!_node.active) continue;
		
		var _startNode = _node.isRenderable(true);
		if(_startNode) {
			ds_queue_enqueue(_queue, _node);
			printIf(global.RENDER_LOG, "Push node " + _node.name + " to stack");
		}
	}
}

function __nodeInLoop(_node) {
	var gr = _node.group;
	while(gr != -1) {
		if(instanceof(gr) == "Node_Iterate")  return true;
		if(instanceof(gr) == "Node_Feedback") return true;
		gr = gr.group;
	}
	return false;
}

function Render(partial = false) {
	UPDATE_STEP++;
	
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
			if(!is_struct(_node)) continue;
			if(instanceof(_node) == "Node_Group_Input") continue;
			if(instanceof(_node) == "Node_Iterator_Input") continue;
		
			if(!_node.active) continue;
			if(_node.rendered) continue;
			if(__nodeInLoop(_node)) continue;
		
			var _startNode = _node.isRenderable();
			if(_startNode) {
				ds_queue_enqueue(RENDER_QUEUE, _node);
				printIf(global.RENDER_LOG, "    > Push " + _node.name + " node to stack");
			}
		}
	
		// render forward
		while(!ds_queue_empty(RENDER_QUEUE)) {
			rendering = ds_queue_dequeue(RENDER_QUEUE);
		
			var txt = rendering.rendered? " [Skip]" : " [Update]";
			if(!rendering.rendered) {
				rendering.doUpdate();
				rendering.setRenderStatus(true);
			}
			printIf(global.RENDER_LOG, "Rendered " + rendering.name + " [" + string(instanceof(rendering)) + "]" + txt);
			rendering.getNextNodes();
		}
	
		printIf(global.RENDER_LOG, "=== RENDER COMPLETE IN {" + string(current_time - t) + "ms} ===\n");
	} catch(e)
		noti_warning("Rendering error: " + exception_print(e));
}