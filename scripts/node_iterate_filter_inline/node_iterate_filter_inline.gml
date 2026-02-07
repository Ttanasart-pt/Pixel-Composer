function Node_Iterate_Filter_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "Filter Array";
	color = COLORS.node_blend_loop;
	
	is_root     = false;
	input_node  = noone;
	output_node = noone;
	
	input_node_types  = [ Node_Iterator_Filter_Inline_Input ];
	output_node_types = [ Node_Iterator_Filter_Inline_Output ];
	
	iteration_count  = 0;
	iterated         = 0;
	
	if(!LOADING && !APPENDING) {
		var input  = nodeBuild("Node_Iterator_Filter_Inline_Input",  x,       y, self);
		var output = nodeBuild("Node_Iterator_Filter_Inline_Output", x + 256, y, self);
		
		if(!CLONING) output.inputs[0].setFrom(input.outputs[0]);
		
		addNode(input);
		addNode(output);
		
		input_node  = input;
		output_node = output;
		
		input_node.loop  = self;
		output_node.loop = self;
		
		if(CLONING && is_instanceof(CLONING_GROUP, Node_Iterate_Filter_Inline)) {
			APPEND_MAP[? CLONING_GROUP.input_node.node_id]  = input.node_id;
			APPEND_MAP[? CLONING_GROUP.output_node.node_id] = output.node_id;
			
			array_push(APPEND_LIST, input, output);
		}
	}
	
	static getIterationCount = function() {
		var _arr = input_node.inputs[0].getValue();
		return array_length(_arr);
	}
	
	static bypassNextNode = function() {
		return iterated < getIterationCount();
	}
	
	static getNextNodes = function(checkLoop = false) {
		LOG_BLOCK_START	
		if(global.FLAG.render == 1) LOG("[outputNextNode] Get next node from inline iterate");
		
		resetRender();
		if(global.FLAG.render == 1) LOG($"Loop restart: iteration {iterated}");
		var _nodes = __nodeLeafList(nodes);
		array_push_unique(_nodes, input_node);
		iterated++;
		
		LOG_BLOCK_END
		
		return _nodes;
	}
	
	static refreshMember = function() {
		nodes = [];
		
		for( var i = 0, n = array_length(attributes.members); i < n; i++ ) {
			var m = attributes.members[i];
			
			if(!ds_map_exists(PROJECT.nodeMap, m))
				continue;
			
			var _node = PROJECT.nodeMap[? m];
			_node.inline_context = self;
			array_push(nodes, _node);
			
			if(is_instanceof(_node, Node_Iterator_Filter_Inline_Input)) {
				input_node = _node;
				input_node.loop = self;
			}
			
			if(is_instanceof(_node, Node_Iterator_Filter_Inline_Output)) {
				output_node = _node;
				output_node.loop = self;
			}
		}
		
		if(input_node == noone || output_node == noone) {
			if(input_node)  input_node.destroy();
			if(output_node) output_node.destroy();
			destroy();
		}
	}
	
	static update = function() {
		if(input_node == noone || output_node == noone) {
			if(input_node)  input_node.destroy();
			if(output_node) output_node.destroy();
			destroy();
			return;
		}
		
		var _itc = getIterationCount();
		if(_itc != iteration_count) RENDER_ALL_REORDER
		iteration_count = _itc;
		iterated        = 0;
		
		output_node.outputs[0].setValue([]);
	}
	
}