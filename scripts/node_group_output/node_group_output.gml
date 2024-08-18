function Node_Group_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Group Output";
	color		= COLORS.node_blend_collection;
	is_group_io = true;
	destroy_when_upgroup = true;
	
	skipDefault();
	setDimension(96, 32 + 24);
	
	newInput(0, nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1))
		.uncache()
		.setVisible(true, true);
	inputs[0].onSetFrom = function(juncFrom) /*=>*/ { if(attributes.inherit_name && !LOADING && !APPENDING) setDisplayName(juncFrom.name); }
	
	attributes.inherit_name = true;
	outParent   			= undefined;
	output_index			= -1;
	
	onSetDisplayName = function() /*=>*/ { attributes.inherit_name = false; }
	
	static setRenderStatus = function(result) {
		if(rendered == result) return;
		LOG_LINE_IF(global.FLAG.render == 1, $"Set render status for {INAME} : {result}");
		
		rendered = result;
		if(group) group.setRenderStatus(result);
	}
	
	static onValueUpdate = function(index = 0) { if(is_undefined(outParent)) return; }
	
	static getNextNodes = function() {
		if(is_undefined(outParent)) return [];
		
		LOG_BLOCK_START();
		var nodes = [];
		for(var j = 0; j < array_length(outParent.value_to); j++) {
			var _to = outParent.value_to[j];
			
			if(!_to.node.isRenderActive())					continue;
			if(!_to.node.active || _to.value_from == noone) continue;
			if(_to.value_from.node != group)				continue;
			
			array_push(nodes, _to.node);
			LOG_IF(global.FLAG.render == 1, $"Check complete, push {_to.node.internalName} to queue.");
		}
		LOG_BLOCK_END();
		
		return nodes;
	}
	
	static createOutput = function() {
		if(group == noone) return;
		if(!is_struct(group)) return;
		
		if(!is_undefined(outParent)) array_remove(group.outputs, outParent);
			
		outParent = nodeValue("Value", group, JUNCTION_CONNECT.output, VALUE_TYPE.any, -1)
			.uncache()
			.setVisible(true, true);
		outParent.from = self;
		
		array_push(group.outputs, outParent);
		
		if(!LOADING && !APPENDING) {
			group.refreshNodeDisplay();
			group.sortIO();
			group.setHeight();
		}
		
	} if(!LOADING && !APPENDING) createOutput();
	
	static step = function() {
		if(is_undefined(outParent)) return;
		
		outParent.name = display_name; 
		
		var _in0 = inputs[0];
		var _pty = _in0.type;
		var _typ = _in0.value_from == noone? VALUE_TYPE.any         : _in0.value_from.type;
		var _dis = _in0.value_from == noone? VALUE_DISPLAY._default : _in0.value_from.display_type;
		
		_in0.setType(_typ);
		_in0.display_type = _dis;
		
		outParent.setType(_in0.type);
		outParent.display_type = _in0.display_type;
		
		if(group && _pty != _typ) group.setHeight();
	}
	
	static update = function() {
		outParent.setValue(inputs[0].getValue());
	}
	
	static getGraphPreviewSurface = function() { return inputs[0].getValue(); }
	static postDeserialize		  = function() { if(group == noone) return; createOutput(false); }
	static doApplyDeserialize	  = function() {}
	
	static onDestroy = function() {
		if(is_undefined(outParent)) return;
		
		array_remove(group.outputs, outParent);
		group.sortIO();
		group.refreshNodes();
		
		var _tos = outParent.getJunctionTo();
		
		for (var i = 0, n = array_length(_tos); i < n; i++) 
			_tos[i].removeFrom();
		
	}
	
	static onUngroup = function() {
		var fr = inputs[0].value_from;
		
		for( var i = 0; i < array_length(outParent.value_to); i++ ) {
			var to = outParent.value_to[i];
			if(to.value_from != outParent) continue;
			
			to.setFrom(fr);
		}
	}
		
	static onLoadGroup = function() { if(group == noone) destroy(); }
}