function Node_Group_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Group Output";
	color = COLORS.node_blend_collection;
	previewable = false;
	
	destroy_when_upgroup = true;
	
	attributes.input_priority = 0;
	if(!CLONING && !LOADING && !APPENDING && group != noone) attributes.input_priority = group.getOutputFreeOrder();
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1)
		.uncache()
		.setVisible(true, true);
	
	attributes.inherit_name = !LOADING && !APPENDING;
	outParent    = undefined;
	output_index = -1;
	
	_onSetDisplayName = function() { attributes.inherit_name = false; }
	
	static setRenderStatus = function(result) { #region
		if(rendered == result) return;
		LOG_LINE_IF(global.FLAG.render == 1, $"Set render status for {INAME} : {result}");
		
		rendered = result;
		if(group) group.setRenderStatus(result);
	} #endregion
	
	static onValueUpdate = function(index = 0) { #region
		if(is_undefined(outParent)) return;
	} #endregion
	
	static getNextNodes = function() { #region
		if(is_undefined(outParent)) return [];
		//group.setRenderStatus(true);
		//printIf(global.FLAG.render, "Value to amount " + string(ds_list_size(outParent.value_to)));
		
		LOG_BLOCK_START();
		var nodes = [];
		for(var j = 0; j < ds_list_size(outParent.value_to); j++) {
			var _to = outParent.value_to[| j];
			if(!_to.node.isRenderActive()) continue;
			//printIf(global.FLAG.render, "Value to " + _to.name);
			
			if(!_to.node.active || _to.isLeaf()) {
				//printIf(global.FLAG.render, "no value from");
				continue; 
			}
			
			if(_to.value_from.node != group) {
				//printIf(global.FLAG.render, "value from not equal group");
				continue; 
			}
				
			//printIf(global.FLAG.render, "Group output ready " + string(_to.node.isRenderable()));
			
			array_push(nodes, _to.node);
			LOG_IF(global.FLAG.render == 1, $"Check complete, push {_to.node.internalName} to queue.");
		}
		LOG_BLOCK_END();
		
		return nodes;
	} #endregion
	
	static createOutput = function() { #region
		if(group == noone) return;
		if(!is_struct(group)) return;
		
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
	} if(!LOADING && !APPENDING) createOutput(); #endregion
	
	static step = function() { #region
		if(is_undefined(outParent)) return;
		
		outParent.name = display_name; 
		
		inputs[| 0].setType(VALUE_TYPE.any);
		if(inputs[| 0].value_from != noone) {
			inputs[| 0].setType(inputs[| 0].value_from.type);
			inputs[| 0].display_type = inputs[| 0].value_from.display_type;
		} 
		
		outParent.setType(inputs[| 0].type);
		outParent.display_type = inputs[| 0].display_type;
		
		onSetDisplayName = _onSetDisplayName;
		if(attributes.inherit_name && inputs[| 0].value_from != noone) {
			if(display_name != inputs[| 0].value_from.name) {
				onSetDisplayName = noone;
				setDisplayName(inputs[| 0].value_from.name);
			}
		}
	} #endregion
	
	static postDeserialize = function() { #region
		if(group == noone) return;
		
		createOutput(false);
		
		if(PROJECT.version < 11520) attributes.input_priority = getInputData(1);
		group.sortIO();
	} #endregion
	
	static doApplyDeserialize = function() { #region
		if(CLONING) attributes.input_priority = group.getOutputFreeOrder();
	} #endregion
	
	static onDestroy = function() { #region
		if(is_undefined(outParent)) return;
		ds_list_remove(group.outputs, outParent);
		group.sortIO();
	} #endregion
	
	static ungroup = function() { #region
		var fr = inputs[| 0].value_from;
		
		for( var i = 0; i < ds_list_size(outParent.value_to); i++ ) {
			var to = outParent.value_to[| i];
			if(to.value_from != outParent) continue;
			
			to.setFrom(fr);
		}
	} #endregion
		
	static onLoadGroup = function() { #region
		if(group == noone) nodeDelete(self);
	} #endregion
}