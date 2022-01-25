enum RENDER_TYPE {
	none = 0,
	partial = 1,
	full = 2
}

function renderAll() {
	var _key = ds_map_find_first(NODE_MAP);
	var amo = ds_map_size(NODE_MAP);
	
	repeat(amo) {
		var _node = NODE_MAP[? _key];
		_node.setRenderStatus(false);
		_key = ds_map_find_next(NODE_MAP, _key);	
	}
	
	ds_stack_clear(RENDER_STACK);
	// get leaf node
	var key = ds_map_find_first(NODE_MAP);
	repeat(ds_map_size(NODE_MAP)) {
		var _node = NODE_MAP[? key];
		key = ds_map_find_next(NODE_MAP, key);
		
		if(instanceof(_node) == "Node_Group_Input") continue;
		if(instanceof(_node) == "Node_Iterator_Input") continue;
		
		if(_node.active && !is_undefined(_node) && is_struct(_node)) {
			var _startNode = true;
			for(var j = 0; j < ds_list_size(_node.inputs); j++) {
				var _in = _node.inputs[| j];
				if(_in.value_from != noone)
					_startNode = false;
			}
			if(_startNode)
				ds_stack_push(RENDER_STACK, _node);
		}
	}
	
	renderUpdated();
}

function __nodeLeafList(_list, _stack) {
	for( var i = 0; i < ds_list_size(_list); i++ ) {
		var _node = _list[| i];
		if(_node.active && !is_undefined(_node) && is_struct(_node)) {
			var _startNode = true;
			for(var j = 0; j < ds_list_size(_node.inputs); j++) {
				var _in = _node.inputs[| j];
				_node.setRenderStatus(false);
					
				if(_in.value_from != noone)
					_startNode = false;
			}
			if(_startNode)
				ds_stack_push(_stack, _node);
		}
	}
}

function renderUpdated() {
	var rendering = noone;
	var error = 0;
	
	//show_debug_message("\n=== RENDER ===")
	
	// render forward
	while(!ds_stack_empty(RENDER_STACK)) {
		rendering = ds_stack_pop(RENDER_STACK);
		
		if(rendering.rendered) continue;
		
		var txt = "rendering " + rendering.name + " ";
		
		if(LOADING || APPENDING || rendering.auto_update) {
			rendering.doUpdate();
			txt += "| Updated ";
		}
		rendering.setRenderStatus(true);
		
		if(instanceof(rendering) == "Node_Group") { //Put each input node in group to stack
			for(var i = rendering.custom_input_index; i < ds_list_size(rendering.inputs); i++) {
				var _in = rendering.inputs[| i].from;
				
				if(_in.isUpdateReady()) ds_stack_push(RENDER_STACK, _in);
			}
		} else if(instanceof(rendering) == "Node_Group_Output") { //Group output in-junction connect automatically to parent out-junction
			var _ot = rendering.outParent;
			for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
				var _to = _ot.value_to[| j];
				
				if(_to.node.active && _to.value_from != noone && _to.value_from.node == rendering.group) {
					_to.node.setRenderStatus(false);
					if(_to.node.isUpdateReady()) ds_stack_push(RENDER_STACK, _to.node);
				}
			}
			
			rendering.group.setRenderStatus(true);
		} else if(instanceof(rendering) == "Node_Iterate") { //Put each input node in group to stack
			for(var i = rendering.custom_input_index; i < ds_list_size(rendering.inputs); i++) {
				var _in = rendering.inputs[| i].from;
				if(_in.isUpdateReady()) ds_stack_push(RENDER_STACK, _in);
			}
		} else if(instanceof(rendering) == "Node_Iterator_Output") { //Check iteration result 
			var _node_it = rendering.group;
			var _ren = _node_it.outputRendered();
			
			if(_ren == 1) { //Go back to the beginning of the loop, reset render status for leaf node inside?
				//show_debug_message("iteration restart");
				var _ot = rendering.group.inputs;
				for(var j = 1; j < ds_list_size(_ot); j++) {
					if(_ot[| j].from.isUpdateReady()) ds_stack_push(RENDER_STACK, _ot[| j].from);
				}
				
				__nodeLeafList(rendering.group.nodes, RENDER_STACK);
			} else if(_ren == 2) { //Go out of loop
				//show_debug_message("iteration completed");
				var _ot = rendering.outParent;
				for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
					var _to = _ot.value_to[| j];
				
					if(_to.node.active && _to.value_from != noone && _to.value_from.node == rendering.group) {
						_to.node.setRenderStatus(false);
						if(_to.node.isUpdateReady()) ds_stack_push(RENDER_STACK, _to.node);
					}
				}
				rendering.group.setRenderStatus(true);
			}
		} else { //push next node
			for(var i = 0; i < ds_list_size(rendering.outputs); i++) {
				var _ot = rendering.outputs[| i];
				
				for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
					var _to = _ot.value_to[| j];
					
					if(_to.node.active && _to.value_from != noone && _to.value_from.node == rendering) {
						_to.node.setRenderStatus(false);
						if(_to.node.isUpdateReady()) ds_stack_push(RENDER_STACK, _to.node);
					}
				}
			}
		}
		
		//show_debug_message(txt);
	}
}
/*
function renderNodeBackward(_node) { //unused
	var RENDER_STACK = ds_stack_create();
	ds_stack_push(RENDER_STACK, _node);
	
	var key = ds_map_find_first(NODE_MAP);
	for(var i = 0; i < ds_map_size(NODE_MAP); i++) {
		var _allnode = NODE_MAP[? key];
		if(_allnode && !is_undefined(_allnode) && is_struct(_allnode) && string_pos("Node", instanceof(_allnode)))
			_allnode.setRenderStatus(false);
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