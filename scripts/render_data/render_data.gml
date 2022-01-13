function NODE_rerender() {
	var _key = ds_map_find_first(NODE_MAP);
	
	for(var i = 0; i < ds_map_size(NODE_MAP); i++) {
		var _node = NODE_MAP[? _key];
		_node.rendered = false;
		_key = ds_map_find_next(NODE_MAP, _key);	
	}
	
	renderAll();
}

function renderAll() {
	var render_q = ds_queue_create();
	var rendering = noone;
	
	var key = ds_map_find_first(NODE_MAP);
	repeat(ds_map_size(NODE_MAP)) {
		var _node = NODE_MAP[? key];
		if(_node.active && !is_undefined(_node) && is_struct(_node)) {
			var _startNode = true;
			for(var j = 0; j < ds_list_size(_node.inputs); j++) {
				var _in = _node.inputs[| j];
					
				if(_in.value_from != noone) { //init
					_startNode = false;
				}
			}
			if(_startNode)
				ds_queue_enqueue(render_q, _node);
		}
		key = ds_map_find_next(NODE_MAP, key);
	}
	
	while(!ds_queue_empty(render_q)) {
		rendering = ds_queue_dequeue(render_q);
			
		var _ready = true;
		for(var j = 0; j < ds_list_size(rendering.inputs); j++) {
			var _in = rendering.inputs[| j];
			if(_in.value_from && !_in.value_from.node.rendered) {
				_ready = false;
			}
		}
				
		if(_ready) {
			if(!rendering.rendered && (LOADING || rendering.auto_update)) 
				rendering.update();
		} else {
			ds_queue_enqueue(render_q, rendering);
		}
		
		if(instanceof(rendering) == "Node_Group_Output") {
			var _ot = rendering._outParent;
			for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
				var _to = _ot.value_to[| j];
				
				if(_to.node.active && _to.value_from != noone && _to.value_from.node == rendering.group) {
					_to.node.rendered = false;
					ds_queue_enqueue(render_q, _to.node);
				}
			}
		} else {
			for(var i = 0; i < ds_list_size(rendering.outputs); i++) {
				var _ot = rendering.outputs[| i];
				
				for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
					var _to = _ot.value_to[| j];
					
					if(_to.node.active && _to.value_from != noone && _to.value_from.node == rendering) {
						_to.node.rendered = false;
						ds_queue_enqueue(render_q, _to.node);
					}
				}
			}
		}
		
		rendering.rendered = true;
	}
		
	ds_queue_destroy(render_q);
}

function renderNodeBackward(_node) {
	var render_st = ds_stack_create();
	ds_stack_push(render_st, _node);
	
	var key = ds_map_find_first(NODE_MAP);
	for(var i = 0; i < ds_map_size(NODE_MAP); i++) {
		var _allnode = NODE_MAP[? key];
		if(_allnode && !is_undefined(_allnode) && is_struct(_allnode) && string_pos("Node", instanceof(_allnode)))
			_allnode.rendered = false;
		key = ds_map_find_next(NODE_MAP, key);
	}
	
	for(var i = 0; i < ds_list_size(_node.inputs); i++) {
		var _in = _node.inputs[| i];
			
		if(_in.value_from) {
			ds_stack_push(render_st, _in.value_from.node);
		}
	}
		
	while(!ds_stack_empty(render_st)) {
		var _rendering = ds_stack_top(render_st);
		var _leaf = true;
			
		for(var i = 0; i < ds_list_size(_rendering.inputs); i++) {
			var _in = _rendering.inputs[| i];
			if(_in.value_from && !_in.value_from.node.rendered) {
				ds_stack_push(render_st, _in.value_from.node);
				_leaf = false;
			}
		}
			
		if(_leaf) {
			//show_debug_message("Rendering " + _rendering.name + " at " + string(ANIMATOR.current_frame));
			_rendering.rendered = true;
			if(_rendering.use_cache) {
				if(!_rendering.recoverCache())
					_rendering.update();
			} else
				_rendering.update();
			ds_stack_pop(render_st);
		}
	}
		
	ds_stack_destroy(render_st);
}