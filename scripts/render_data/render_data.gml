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
		
		var _startNode = true;
		for(var j = 0; j < ds_list_size(_node.inputs); j++) {
			var _in = _node.inputs[| j];
			_node.triggerRender();
					
			if(_in.value_from != noone && !_in.value_from.node.rendered)
				_startNode = false;
		}
		if(_startNode) {
			ds_stack_push(_stack, _node);
			printIf(global.RENDER_LOG, "Push node " + _node.name + " to stack");
		}
	}
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
		
		var _startNode = true;
		for(var j = 0; j < ds_list_size(_node.inputs); j++) {
			var _in = _node.inputs[| j];
			if(_in.value_from != noone && !_in.value_from.node.rendered)
				_startNode = false;
		}
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
		
		if(instanceof(rendering) == "Node_Group") { //Put each input node in group to stack
			//if(!rendering.isUpdateReady()) continue;
			for(var i = rendering.custom_input_index; i < ds_list_size(rendering.inputs); i++) {
				var _in = rendering.inputs[| i].from;
				
				ds_stack_push(RENDER_STACK, _in);
				printIf(global.RENDER_LOG, "Push group input " + _in.name + " to stack");
			}
		} else if(instanceof(rendering) == "Node_Group_Output") { //Group output in-junction connect automatically to parent out-junction
			rendering.group.setRenderStatus(true);
			var _ot = rendering.outParent;
			printIf(global.RENDER_LOG, "Value to amount " + string(ds_list_size(_ot.value_to)));
			for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
				var _to = _ot.value_to[| j];
				printIf(global.RENDER_LOG, "Value to " + _to.name);
				if(!_to.node.active || _to.value_from == noone) {
					printIf(global.RENDER_LOG, "no value from");
					continue; 
				}
				if(_to.value_from.node != rendering.group) {
					printIf(global.RENDER_LOG, "value from not equal group");
					continue; 
				}
				
				printIf(global.RENDER_LOG, "Group output ready " + string(_to.node.isUpdateReady()));
				//_to.node.triggerRender();
				if(_to.node.isUpdateReady()) {
					ds_stack_push(RENDER_STACK, _to.node);
					printIf(global.RENDER_LOG, "Push node " + _to.node + " to stack");
				}
			}
		} else if(instanceof(rendering) == "Node_Iterate") { //Put each input node in group to stack
			var allReady = true;
			for(var i = rendering.custom_input_index; i < ds_list_size(rendering.inputs); i++) {
				var _in = rendering.inputs[| i].from;
				allReady &= _in.isUpdateReady()
			}
			
			if(allReady) {
				for(var i = rendering.custom_input_index; i < ds_list_size(rendering.inputs); i++) {
					var _in = rendering.inputs[| i].from;	
					ds_stack_push(RENDER_STACK, _in);	
					printIf(global.RENDER_LOG, "    > Push " + _in.name + " node to stack");
				}
				rendering.initLoop();
			}
		} else if(instanceof(rendering) == "Node_Iterator_Output") { //Check iteration result 
			var _node_it = rendering.group;
			var _ren = _node_it.iterationStatus();
			
			if(_ren == ITERATION_STATUS.loop) { //Go back to the beginning of the loop, reset render status for leaf node inside?
				printIf(global.RENDER_LOG, "    > Loop restart: iteration " + string(rendering.group.iterated));
				__nodeLeafList(rendering.group.nodes, RENDER_STACK);
				var loopEnt = rendering.inputs[| 2].value_from.node;
				ds_stack_push(RENDER_STACK, loopEnt);
			} else if(_ren == ITERATION_STATUS.complete) { //Go out of loop
				printIf(global.RENDER_LOG, "    > Loop completed");
				rendering.group.setRenderStatus(true);
				var _ot = rendering.outParent;
				for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
					var _to = _ot.value_to[| j];
				
					if(_to.node.active && _to.value_from != noone && _to.value_from.node == rendering.group) {
						_to.node.triggerRender();
						if(_to.node.isUpdateReady()) ds_stack_push(RENDER_STACK, _to.node);
					}
				}
			} else 
				printIf(global.RENDER_LOG, "    > Loop not ready");
		} else { //push next node
			for(var i = 0; i < ds_list_size(rendering.outputs); i++) {
				var _ot = rendering.outputs[| i];
				if(_ot.type == VALUE_TYPE.node) continue;
				
				for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
					var _to = _ot.value_to[| j];
					if(!_to.node.active || _to.value_from == noone) continue; 
					if(_to.value_from.node != rendering) continue; 
					
					_to.node.triggerRender();
					if(_to.node.isUpdateReady()) {
						ds_stack_push(RENDER_STACK, _to.node);
						printIf(global.RENDER_LOG, "    > Push " + _to.node.name + " node to stack");
					} else 
						printIf(global.RENDER_LOG, "    > Node " + _to.node.name + " not ready");
				}
			}
		}
		
		//show_debug_message(txt);
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