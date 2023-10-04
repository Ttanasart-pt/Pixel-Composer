function Node_Group_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Group Output";
	destroy_when_upgroup = true;
	color = COLORS.node_blend_collection;
	previewable = false;
	auto_height = false;
	
	attributes.input_priority = group == noone? 0 : ds_list_size(group.inputs);
	array_push(attributeEditors, "Group");
	array_push(attributeEditors, ["Input Order", function() { return attributes.input_priority; }, 
		new textBox(TEXTBOX_INPUT.number, function(val) { 
			attributes.input_priority = val; 
			group.setHeight();
			group.sortIO();
		})]);
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1)
		.uncache()
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Order", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.uncache()
		.rejectArray();
	
	attributes.inherit_name = !LOADING && !APPENDING;
	outParent = undefined;
	output_index = -1;
	
	_onSetDisplayName = function() {
		attributes.inherit_name = false;
	}
	
	static setRenderStatus = function(result) {
		LOG_LINE_IF(global.FLAG.render, $"Set render status for {INAME} : {result}");
		
		rendered = result;
		if(group) group.setRenderStatus(result);
	}
	
	static onValueUpdate = function(index = 0) {
		if(is_undefined(outParent)) return;
		
		group.sortIO();
	}
	
	static getNextNodes = function() {
		if(is_undefined(outParent)) return [];
		//group.setRenderStatus(true);
		//printIf(global.FLAG.render, "Value to amount " + string(ds_list_size(outParent.value_to)));
		
		LOG_BLOCK_START();
		var nodes = [];
		for(var j = 0; j < ds_list_size(outParent.value_to); j++) {
			var _to = outParent.value_to[| j];
			if(!_to.node.isRenderActive()) continue;
			//printIf(global.FLAG.render, "Value to " + _to.name);
			
			if(!_to.node.active || _to.value_from == noone) {
				//printIf(global.FLAG.render, "no value from");
				continue; 
			}
			
			if(_to.value_from.node != group) {
				//printIf(global.FLAG.render, "value from not equal group");
				continue; 
			}
				
			//printIf(global.FLAG.render, "Group output ready " + string(_to.node.isRenderable()));
			
			array_push(nodes, _to.node);
			LOG_IF(global.FLAG.render, $"Check complete, push {_to.node.internalName} to queue.");
		}
		LOG_BLOCK_END();
		
		return nodes;
	}
	
	static createOutput = function(override_order = true) {
		if(group == noone) return;
		if(!is_struct(group)) return;
		
		if(override_order)
			attributes.input_priority = ds_list_size(group.outputs);
			
		if(!is_undefined(outParent))
			ds_list_remove(group.outputs, outParent);
			
		outParent = nodeValue("Value", group, JUNCTION_CONNECT.output, VALUE_TYPE.any, -1)
			.uncache()
			.setVisible(true, true);
		outParent.from = self;
			
		ds_list_add(group.outputs, outParent);
		group.setHeight();
		group.sortIO();
		
		outParent.setFrom(inputs[| 0]);
	}
	
	if(!LOADING && !APPENDING)
		createOutput();
	
	static step = function() {
		if(is_undefined(outParent)) return;
		
		outParent.name = display_name; 
		
		inputs[| 0].type = VALUE_TYPE.any;
		if(inputs[| 0].value_from != noone) {
			inputs[| 0].type = inputs[| 0].value_from.type;
			inputs[| 0].display_type = inputs[| 0].value_from.display_type;
		} 
		
		outParent.type = inputs[| 0].type;
		outParent.display_type = inputs[| 0].display_type;
		
		onSetDisplayName = _onSetDisplayName;
		if(attributes.inherit_name && inputs[| 0].value_from != noone) {
			if(display_name != inputs[| 0].value_from.name) {
				onSetDisplayName = noone;
				setDisplayName(inputs[| 0].value_from.name);
			}
		}
	}
	
	//static triggerRender = function() {
	//	if(is_undefined(outParent)) return;
		
	//	for(var j = 0; j < ds_list_size(outParent.value_to); j++) {
	//		if(outParent.value_to[| j].value_from == outParent)
	//			outParent.value_to[| j].node.triggerRender();
	//	}
	//}
	
	static postDeserialize = function() {
		createOutput(false);
		
		var _inputs = load_map.inputs;
		inputs[| 1].applyDeserialize(_inputs[1], load_scale);
		if(PROJECT.version < 11520) attributes.input_priority = getInputData(1);
		group.sortIO();
	}
	
	static onDestroy = function() {
		if(is_undefined(outParent)) return;
		ds_list_delete(group.outputs, ds_list_find_index(group.outputs, outParent));
	}
	
	static ungroup = function() {
		var fr = inputs[| 0].value_from;
		
		for( var i = 0; i < ds_list_size(outParent.value_to); i++ ) {
			var to = outParent.value_to[| i];
			if(to.value_from != outParent) continue;
			
			to.setFrom(fr);
		}
	}
}