enum RENDER_TYPE {
	none = 0,
	partial = 1,
	full = 2
}

global.RENDER_LOG = false;

function __nodeLeafList(_list, _stack) {
	for( var i = 0; i < ds_list_size(_list); i++ ) {
		var _node = _list[| i];
		if(!_node.active) continue;
		
		var _startNode = _node.isRenderable(true);
		if(_startNode) {
			ds_stack_push(_stack, _node);
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
	var rendering = noone;
	var error = 0;
	printIf(global.RENDER_LOG, "=== RENDER START ===");
	
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
	ds_stack_clear(RENDER_STACK);
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
			ds_stack_push(RENDER_STACK, _node);
			printIf(global.RENDER_LOG, "    > Push " + _node.name + " node to stack");
		}
	}
	
	// render forward
	while(!ds_stack_empty(RENDER_STACK)) {
		rendering = ds_stack_pop(RENDER_STACK);
		
		var txt = rendering.rendered? " [Skip]" : " [Update]";
		if(!rendering.rendered) {
			if(LOADING || APPENDING || rendering.auto_update)
				rendering.doUpdate();
			rendering.setRenderStatus(true);
		}
		printIf(global.RENDER_LOG, "Rendered " + rendering.name + " [" + string(instanceof(rendering)) + "]" + txt);
		rendering.getNextNodes();
	}
	
	printIf(global.RENDER_LOG, "=== RENDER COMPLETE ===\n");
}
/*
function renderNodeBackward(_node) { //unused
	var RENDER_STACK = ds_stack_create();
	ds_stack_push(RENDER_STACK, _node);
	
	var key = ds_map_find_first(NODE_MAP);
	for(var i = 0; i < ds_map_size(NODE_MAP); i++) {
		var _allnode = NODE_MAP[? key];
		if(_allnode && !is_undefined(_allnode) && is_struct(_allnode) && string_pos("Node", instanceof(_allnode)))
			_allnode.triggerRender();
		key = ds_map_find_next(NODE_MAP, key);
	}
	
	for(var i = 0; i < ds_list_size(_node.inputs); i++) {
		var _in = _node.inputs[| i];
			
		if(_in.value_from) {
			ds_stack_push(RENDER_STACK, _in.value_from.node);
		}
	}
		
	while(!ds_stack_empty(RENDER_STACK)) {
		var _rendering = ds_stack_top(RENDER_STACK);
		var _leaf = true;
			
		for(var i = 0; i < ds_list_size(_rendering.inputs); i++) {
			var _in = _rendering.inputs[| i];
			if(_in.value_from && !_in.value_from.node.rendered) {
				ds_stack_push(RENDER_STACK, _in.value_from.node);
				_leaf = false;
			}
		}
			
		if(_leaf) {
			//show_debug_message("Rendering " + _rendering.name + " at " + string(ANIMATOR.current_frame));
			_rendering.setRenderStatus(true);
			if(_rendering.use_cache) {
				if(!_rendering.recoverCache())
					_rendering.doUpdate();
			} else
				_rendering.doUpdate();
			ds_stack_pop(RENDER_STACK);
		}
	}
		
	ds_stack_destroy(RENDER_STACK);
}