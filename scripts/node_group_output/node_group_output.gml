function Node_create_Group_Output(_x, _y) {
	if(!LOADING && !APPENDING && PANEL_GRAPH.getCurrentContext() == -1) return;
	var node = new Node_Group_Output(_x, _y, PANEL_GRAPH.getCurrentContext());
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Group_Output(_x, _y, _group) : Node(_x, _y) constructor {
	name  = "Output";
	color = c_ui_yellow;
	previewable = false;
	auto_height = false;
	
	self.group = _group;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue(0, "Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1);
	
	_outParent = -1;
	
	function createOutput() {
		_outParent = nodeValue(ds_list_size(group.outputs), "Value", group, JUNCTION_CONNECT.output, VALUE_TYPE.any, -1);
		ds_list_add(group.outputs, _outParent);
		group.setHeight();
		
		_outParent.setFrom(inputs[| 0]);
	}
	if(!LOADING && !APPENDING)
		createOutput();
	
	function step() {
		_outParent.name = name; 

		if(inputs[| 0].value_from) {
			_outParent.type  = inputs[| 0].value_from.type;
			inputs[| 0].type = inputs[| 0].value_from.type;
		} else {
			inputs[| 0].type = VALUE_TYPE.any;
		}
	}
	function doUpdateForward() {
		if(_outParent == -1) return;
		
		for(var j = 0; j < ds_list_size(_outParent.value_to); j++) {
			if(_outParent.value_to[| j].value_from == _outParent) {
				_outParent.value_to[| j].node.updateForward();
			}
		}
	}
	
	function doConnect() {
		createOutput();
	}
	
	function onDestroy() {
		ds_list_delete(group.outputs, ds_list_find_index(group.outputs, _outParent));
	}
}