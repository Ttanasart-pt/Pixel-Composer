function Node_Collection(_x,  _y) : Node(_x,  _y) constructor {
	nodes = ds_list_create();
	
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
		_node.group = group;
	}
	
	function stepBegin() {
		for(var i = 0; i < ds_list_size(nodes); i++) {
			nodes[| i].stepBegin();
		}
	}
	
	function step() {
		for(var i = 0; i < ds_list_size(nodes); i++) {
			nodes[| i].step();
		}
		
		if(PANEL_GRAPH.node_focus == self && FOCUS == PANEL_GRAPH.panel && DOUBLE_CLICK) {
			PANEL_GRAPH.addContext(self);
			DOUBLE_CLICK = false;
		}
	}
	
	load_map = -1;
	
	function doDeserialize(map) {
		load_map = ds_map_create();
		ds_map_copy(load_map, map);
	}
	
	static doConnect = function() {
		deserialize(load_map, keyframe_scale);
		ds_map_destroy(load_map);
	}
}