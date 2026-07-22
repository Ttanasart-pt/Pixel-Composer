function Node_Iterator_Reduce_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "Reduce Array";
	color = COLORS.node_blend_loop;
	
	is_root     = false;
	input_node  = noone;
	output_node = noone;
	
	iteration_count  = 0;
	iterated         = 0;
	
	if(!LOADING && !APPENDING) {
		var input  = nodeBuild("Node_Iterator_Reduce_Input",  x,       y, self);
		var output = nodeBuild("Node_Iterator_Reduce_Output", x + 256, y, self);
		
		if(!CLONING) output.inputs[0].setFrom(input.outputs[0]);
		
		addNode(input);
		addNode(output);
		
		input_node  = input;
		output_node = output;
		
		input_node.loop  = self;
		output_node.loop = self;
		
		if(CLONING && is(CLONING_GROUP, Node_Iterate_Sort_Inline)) {
			APPEND_MAP[? CLONING_GROUP.input_node.node_id]  = input.node_id;
			APPEND_MAP[? CLONING_GROUP.output_node.node_id] = output.node_id;
			
			array_push(APPEND_LIST, input, output);
		}
	}
	
	static getIterationCount = function() /*=>*/ {return array_safe_length(input_node.inputs[0].getValue())};
	static bypassNextNode    = function() /*=>*/ {return iterated < getIterationCount()}; // Used by output to decided what node to render next
	
	static getNextNodes = function() {
		LOG_BLOCK_START	
		if(global.FLAG.render == 1) LOG("[outputNextNode] Get next node from inline iterate");
		
		resetRender();
		var _nodes = __nodeLeafList(nodes);
		array_push_unique(_nodes, input_node);
		iterated++;
		
		LOG_BLOCK_END
		logNodeDebug($"Loop restart: iteration {iterated} : {array_length(_nodes)} leaf", 2);
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
			
			if(is(_node, Node_Iterator_Reduce_Input)) {
				input_node = _node;
				input_node.loop = self;
			}
			
			if(is(_node, Node_Iterator_Reduce_Output)) {
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
		if(_itc != iteration_count) RenderAllReorder();
		iteration_count = _itc;
		iterated        = 0;
	}
	
}