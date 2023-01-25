function Node_Group_Output(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name  = "Output";
	color = COLORS.node_blend_collection;
	previewable = false;
	auto_height = false;
	
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
	
	static getNextNodes = function() {
		if(is_undefined(outParent)) return;
		group.setRenderStatus(true);
		//printIf(global.RENDER_LOG, "Value to amount " + string(ds_list_size(outParent.value_to)));
		
		for(var j = 0; j < ds_list_size(outParent.value_to); j++) {
			var _to = outParent.value_to[| j];
			printIf(global.RENDER_LOG, "Value to " + _to.name);
			
			if(!_to.node.active || _to.value_from == noone) {
				printIf(global.RENDER_LOG, "no value from");
				continue; 
			}
			
			if(_to.value_from.node != group) {
				printIf(global.RENDER_LOG, "value from not equal group");
				continue; 
			}
				
			printIf(global.RENDER_LOG, "Group output ready " + string(_to.node.isUpdateReady()));
			
			if(_to.node.isUpdateReady()) {
				ds_queue_enqueue(RENDER_QUEUE, _to.node);
				printIf(global.RENDER_LOG, "Push node " + _to.node.name + " to stack");
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
		
		inputs[| 0].type = VALUE_TYPE.any;
		if(inputs[| 0].value_from != noone) {
			inputs[| 0].type = inputs[| 0].value_from.type;
			inputs[| 0].display_type = inputs[| 0].value_from.display_type;
		} 
		
		outParent.type = inputs[| 0].type;
		outParent.display_type = inputs[| 0].display_type;
	}
	
	static triggerRender = function() {
		if(is_undefined(outParent)) return;
		
		for(var j = 0; j < ds_list_size(outParent.value_to); j++) {
			if(outParent.value_to[| j].value_from == outParent)
				outParent.value_to[| j].node.triggerRender();
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