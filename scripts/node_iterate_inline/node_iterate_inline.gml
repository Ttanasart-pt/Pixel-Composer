function Node_Iterate_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name    = "Loop";
	color   = COLORS.node_blend_loop;
	icon    = THEME.loop;
	icon_24 = THEME.loop_24;
	is_root = false;
	
	newInput(0, nodeValue_Int("Repeat", 1 )).uncache();
	
	managedRenderOrder = true;
	
	attributes.junc_in  = [ "", 0 ];
	attributes.junc_out = [ "", 0 ];
	
	junc_in  = noone;
	junc_out = noone;
	
	value_buffer    = undefined;
	iteration_count = 0;
	iterated        = 0;
	
	static getIterationCount = function() { return getInputData(0); }
	static bypassConnection  = function() { return iterated > 1 && !is_undefined(value_buffer); }
	static bypassNextNode    = function() { return iterated < getIterationCount(); }
	
	static getNextNodes = function(checkLoop = false) {
		LOG_BLOCK_START();	
		LOG_IF(global.FLAG.render == 1, "[outputNextNode] Get next node from inline iterate");
		
		resetRender();
		var _nodes = __nodeLeafList(nodes);
		array_push_unique(_nodes, junc_in.node);
		iterated++;
		
		LOG_BLOCK_END();
		logNodeDebug($"Loop restart: iteration {iterated}");
		
		return _nodes;
	}
	
	static connectJunctions = function(jFrom, jTo) {
		junc_in  = jFrom.is_dummy? jFrom.dummy_get() : jFrom;
		junc_out = jTo;
		
		attributes.junc_in  = [ junc_in .node.node_id, junc_in .index ];
		attributes.junc_out = [ junc_out.node.node_id, junc_out.index ];
		
		scanJunc();
	}
	
	static scanJunc = function() {
		var node_in  = PROJECT.nodeMap[? attributes.junc_in[0]];
		var node_out = PROJECT.nodeMap[? attributes.junc_out[0]];
		
		junc_in  = noone;
		junc_out = noone;
		
		if(node_in)  junc_in  = array_safe_get(node_in.inputs,   attributes.junc_in[1]);
		if(node_out) junc_out = array_safe_get(node_out.outputs, attributes.junc_out[1]);
		
		if(junc_in)  { 
			junc_in.value_from_loop = self;
			junc_in.node.refreshNodeDisplay();
			addNode(junc_in.node);
		}
			
		if(junc_out) { 
			array_push(junc_out.value_to_loop, self);
			junc_out.node.refreshNodeDisplay();
			addNode(junc_out.node);
		}
		
	}
	
	static updateValue = function() {
		var type = junc_out.type;
		var val  = junc_out.getValue();
		
		switch(type) {
			case VALUE_TYPE.surface : 
				surface_array_free(value_buffer);
				value_buffer = surface_array_clone(val);
				break;
				
			default :
				value_buffer = variable_clone(val);
				break;
		}
	}
	
	static getValue = function(arr) {
		INLINE
		
		arr[@ 0] = value_buffer;
		arr[@ 1] = junc_out;
	}
	
	static update = function() {
		var _itc = inputs[0].getValue();
		if(_itc != iteration_count) RENDER_ALL_REORDER
		
		iteration_count = _itc;
		iterated        = 0;
		value_buffer    = undefined;
	}
	
	static drawConnections = function(params = {}, _draw = true) {
		var hovering = noone;
		
		params.dashed = true; params.loop   = true;
		if(junc_out && junc_in) drawJuncConnection(junc_out, junc_in, params);
		params.dashed = false; params.loop   = false;
		
		var jun  = inputs[0];
		var _hov = jun.drawConnections(params, _draw); if(_hov) hovering = _hov;
		
		return hovering;
	}
	
	static postDeserialize = function() {
		refreshMember();
		scanJunc();
	}
	
	static onDestroy = function() {
		if(junc_in)  junc_in.value_from_loop = noone;
		if(junc_out) array_remove(junc_out.value_to_loop, self);
	}
}