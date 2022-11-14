enum COLLECTION_TAG {
	group = 1,
	loop = 2
}

function Node_Collection(_x,  _y) : Node(_x,  _y) constructor {
	nodes = ds_list_create();
	
	custom_input_index = 0;
	custom_output_index = 0;
	
	function add(_node) {
		ds_list_add(nodes, _node);
		var list = _node.group == -1? PANEL_GRAPH.nodes_list : _node.group.nodes;
		var _pos = ds_list_find_index(list, _node);
		ds_list_delete(list, _pos);
		
		recordAction(ACTION_TYPE.group_added, self, _node);
		_node.group = self;
	}
	
	function remove(_node) {
		var _pos = ds_list_find_index(nodes, _node);
		ds_list_delete(nodes, _pos);
		var list = group == -1? PANEL_GRAPH.nodes_list : group.nodes;
		ds_list_add(list, _node);
		
		recordAction(ACTION_TYPE.group_removed, self, _node);
		
		switch(instanceof(_node)) {
			case "Node_Group_Input" :
			case "Node_Group_Output" :
			case "Node_Iterator_Input" :
			case "Node_Iterator_Output" :
			case "Node_Iterator_Index" :
				nodeDelete(_node);
				break;
			default : 
				_node.group = group;
		}
	}
	
	static stepBegin = function() {
		for(var i = 0; i < ds_list_size(nodes); i++) {
			nodes[| i].stepBegin();
		}
		
		var out_surf = false;
		
		for( var i = 0; i < ds_list_size(outputs); i++) {
			if(outputs[| i].type == VALUE_TYPE.surface) 
				out_surf = true;
		}
		
		if(out_surf) {
			w = 128;
			min_h = 128;
		} else {
			w = 96;
			min_h = 0;
		}
		
		setHeight();
	}
	
	static step = function() {
		render_time = 0;
		for(var i = 0; i < ds_list_size(nodes); i++) {
			nodes[| i].step();
			render_time += nodes[| i].render_time;
		}
		
		if(PANEL_GRAPH.node_focus == self && panelFocus(PANEL_GRAPH) && DOUBLE_CLICK) {
			PANEL_GRAPH.addContext(self);
			DOUBLE_CLICK = false;
		}
	}
	
	static updateForward = function() {
		doUpdate();
		
		for(var i = custom_input_index; i < ds_list_size(inputs); i++) {
			var jun_node = inputs[| i].from;
			jun_node.updateForward();
		}
		
		doUpdateForward();
	}
	
	static preConnect = function() {
		sortIO();
		deserialize(keyframe_scale);
	}
	
	static sortIO = function() {
		var siz = ds_list_size(inputs);
		var ar = ds_priority_create();
		
		for( var i = custom_input_index; i < siz; i++ ) {
			var _in = inputs[| i];
			var _or = _in.from.inputs[| 5].getValue();
			
			ds_priority_add(ar, _in, _or);
		}
		
		for( var i = siz - 1; i >= custom_input_index; i-- ) {
			ds_list_delete(inputs, i);
		}
		
		for( var i = custom_input_index; i < siz; i++ ) {
			var _jin = ds_priority_delete_min(ar);
			_jin.index = i;
			ds_list_add(inputs, _jin);
		}
		
		ds_priority_destroy(ar);
		
		var siz = ds_list_size(outputs);
		var ar = ds_priority_create();
		
		for( var i = custom_output_index; i < siz; i++ ) {
			var _out = outputs[| i];
			var _or = _out.from.inputs[| 1].getValue();
			
			ds_priority_add(ar, _out, _or);
		}
		
		for( var i = siz - 1; i >= custom_output_index; i-- ) {
			ds_list_delete(outputs, i);
		}
		
		for( var i = custom_output_index; i < siz; i++ ) {
			var _jout = ds_priority_delete_min(ar);
			_jout.index = i;
			ds_list_add(outputs, _jout);
		}
		
		ds_priority_destroy(ar);
	}
	
	static onDestroy = function() {
		for( var i = 0; i < ds_list_size(nodes); i++ ) {
			nodes[| i].destroy();
		}
	}
	
	static resetRenderStatus = function() {
		for( var i = 0; i < ds_list_size(nodes); i++ ) {
			nodes[| i].setRenderStatus(false);
			if(variable_struct_exists(nodes[| i], "nodes"))
				nodes[| i].resetRenderStatus();
		}
	}
}