function Node_create_Iterator_Output(_x, _y) {
	if(!LOADING && !APPENDING && PANEL_GRAPH.getCurrentContext() == -1) return;
	var node = new Node_Iterator_Output(_x, _y, PANEL_GRAPH.getCurrentContext());
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Iterator_Output(_x, _y, _group) : Node(_x, _y) constructor {
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
	
	inputs[| 2] = nodeValue(2, "Use as input", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, -1);
	
	cache_value = -1;
	outParent = undefined;
	output_index = -1;
	
	static onValueUpdate = function(index) {
		if(is_undefined(outParent)) return;
		group.sortIO();
		
		if(index == 2) {
			var _v = inputs[| 2].getValue();
			for( var i = 1; i < ds_list_size(group.inputs); i++ ) {
				var _in = group.inputs[| i].from;
				if(i - 1 == _v) 
					_in.local_output = inputs[| 0];
				else if(_in.local_output == inputs[| 0])
					_in.local_output = noone;
			}
		}
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
	
	static update = function() {
		var _val_get = inputs[| 0].getValue();
		
		switch(inputs[| 0].type) {
			case VALUE_TYPE.surface	: 
				if(is_surface(cache_value)) 
					surface_free(cache_value);
				if(is_surface(_val_get)) 
					cache_value = surface_clone(_val_get);
				break;
			default : 
				cache_value = _val_get;
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