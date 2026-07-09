function Node_Iterate_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name    = "Loop";
	color   = COLORS.node_blend_loop;
	icon    = THEME.loop;
	icon_24 = THEME.loop_24;
	is_root = false;
	managedRenderOrder = true;
	
	loop_active = true;
	loop_valid  = true;
	
	newInput(0, nodeValue_Int(  "Repeat", 1    )).uncache();
	newInput(1, nodeValue_Bool( "Active", true ));
	input_display_list = [ 1,0 ];
	
	attributes.junc_in  = [0,0];
	attributes.junc_out = [0,0];
	
	input_node  = noone;
	output_node = noone;
	
	iteration_count = 0;
	iterated        = 0;
	
	////- Rendering
	
	static connectJunctions = function(jFrom, jTo) {
		var nfrom = jFrom.node;
		var nto   = jTo.node;
		
		var input  = nodeBuild("Node_Iterate_Inline_Input",  nfrom.x - 32 - 96,  nfrom.y);
		var output = nodeBuild("Node_Iterate_Inline_Output", nto.x + nto.w + 32, nto.y);
		
		input.inputs[0].setFrom(jFrom.value_from);
		jFrom.setFrom(input.outputs[0]);
		output.inputs[0].setFrom(jTo);
		
		addNode(input);
		addNode(output);
		addNode(nfrom);
		if(nfrom != nto) addNode(nto);
		
		input_node  = input;
		output_node = output;
		
		input_node.loop  = self;
		output_node.loop = self;
		
		return self;
	}
	
	static getIterationCount = function() /*=>*/ {return getInputData(0)};
	static bypassNextNode    = function() /*=>*/ {return iterated < getIterationCount()};
	
	static getNextNodes = function() {
		LOG_BLOCK_START	
		if(global.FLAG.render == 1) LOG("[outputNextNode] Get next node from inline iterate");
		
		resetRender();
		var _nodes = __nodeLeafList(nodes);
		array_push_unique(_nodes, input_node);
		iterated++;
		
		LOG_BLOCK_END
		logNodeDebug($"Loop [{getDisplayName()}] restart: iteration {iterated}", 1, icon);
		return _nodes;
	}
	
	static refreshMember = function() {
		input_node  = noone;
		output_node = noone;
		nodes = [];
		
		for( var i = 0, n = array_length(attributes.members); i < n; i++ ) {
			var m = attributes.members[i];
			
			if(!ds_map_exists(PROJECT.nodeMap, m))
				continue;
			
			var _node = PROJECT.nodeMap[? m];
			_node.inline_context = self;
			
			array_push(nodes, _node);
			
			if(is(_node, Node_Iterate_Inline_Input)) {
				input_node = _node;
				input_node.loop = self;
			}
			
			if(is(_node, Node_Iterate_Inline_Output)) {
				output_node = _node;
				output_node.loop = self;
			}
		}
		
	}
	
	static update = function() {
		if(input_node == noone || output_node == noone) {
			if(input_node)  input_node.destroy();
			if(output_node) output_node.destroy();
			destroy();
		}
		
		loop_valid  = true;
		loop_active = inputs[1].getValue();
		var _itc    = inputs[0].getValue();
		if(!loop_active) _itc = 0;
		
		if(_itc != iteration_count) RenderAllReorder();
		
		iteration_count = _itc;
		iterated        = 0;
	}
	
	////- Draw
	
	static drawConnections = function(params = {}, _draw = true) {
		if(!loop_valid) return undefined;
		
		var hovering = undefined;
		params.dashed = true; params.loop   = true;
		if(input_node && output_node) drawJuncConnection(output_node.outputs[0], input_node.inputs[0], params);
		params.dashed = false; params.loop   = false;
		
		var jun  = inputs[0];
		var _hov = jun.drawConnections(params, _draw); 
		return _hov? [_hov, undefined] : undefined;
	}
	
	////- Serialize
	
	static postDeserialize = function() {
		if(APPENDING)
		for( var i = 0, n = array_length(attributes.members); i < n; i++ )
			attributes.members[i] = GetAppendID(attributes.members[i]);
			
		refreshMember();
	}
	
	static afterLoad = function() /*=>*/ {
		if(LOADING_VERSION >= 1_21_06_1) return;
		
		var node_in  = project.nodeMap[? attributes.junc_in[0]];
		var node_out = project.nodeMap[? attributes.junc_out[0]];
		
		var junc_in  = node_in?  array_safe_get(node_in.inputs,   attributes.junc_in[1])  : noone;
		var junc_out = node_out? array_safe_get(node_out.outputs, attributes.junc_out[1]) : noone;
		
		if(junc_in && junc_out) connectJunctions(junc_in, junc_out);
	}
	
	////- Action
	
	static onClone = function() {
		attributes.members = [];
	}
	
	static onDestroy = function() {
		if(input_node)  input_node.destroy(); 
		if(output_node) output_node.destroy(); 
	}
}