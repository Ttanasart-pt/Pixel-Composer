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
	
	inputs[| 0] = nodeValue(0, "Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue(1, "Order", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	outParent = undefined;
	output_index = -1;
	
	static onValueUpdate = function(index) {
		if(is_undefined(outParent)) return;
		
		group.sortIO();
	}
	
	static createOutput = function(override_order = true) {
		if(group && is_struct(group)) {
			if(override_order) {
				output_index = ds_list_size(group.outputs);
				inputs[| 1].setValue(output_index);
			} else {
				output_index = inputs[| 1].getValue();
			}
			
			outParent = nodeValue(ds_list_size(group.outputs), "Value", group, JUNCTION_CONNECT.output, VALUE_TYPE.any, -1)
				.setVisible(true, true);
			outParent.from = self;
			
			ds_list_add(group.outputs, outParent);
			group.setHeight();
			group.sortIO();
		
			outParent.setFrom(inputs[| 0]);
		}
	}
	
	if(!LOADING && !APPENDING)
		createOutput();
	
	static step = function() {
		if(is_undefined(outParent)) return;
		
		outParent.name = name; 

		if(inputs[| 0].value_from) {
			outParent.type  = inputs[| 0].value_from.type;
			inputs[| 0].type = inputs[| 0].value_from.type;
		} else {
			inputs[| 0].type = VALUE_TYPE.any;
		}
	}
	static doUpdateForward = function() {
		if(is_undefined(outParent)) return;
		
		for(var j = 0; j < ds_list_size(outParent.value_to); j++) {
			if(outParent.value_to[| j].value_from == outParent) {
				outParent.value_to[| j].node.updateForward();
			}
		}
	}
	
	static postDeserialize = function() {
		createOutput(false);
	}
	
	static onDestroy = function() {
		if(is_undefined(outParent)) return;
		ds_list_delete(group.outputs, ds_list_find_index(group.outputs, outParent));
	}
}