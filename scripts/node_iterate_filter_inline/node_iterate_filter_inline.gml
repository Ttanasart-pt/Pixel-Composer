function Node_Iterate_Filter_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "Filter Array";
	color = COLORS.node_blend_loop;
	
	is_root     = false;
	input_node  = noone;
	output_node = noone;
	
	input_node_type  = Node_Iterator_Filter_Inline_Input;
	output_node_type = Node_Iterator_Filter_Inline_Output;
	iterated         = 0;
	
	if(!LOADING && !APPENDING) { #region
		var input  = nodeBuild("Node_Iterator_Filter_Inline_Input",  x,       y);
		var output = nodeBuild("Node_Iterator_Filter_Inline_Output", x + 256, y);
		
		if(!CLONING) output.inputs[| 0].setFrom(input.outputs[| 0]);
		
		addNode(input);
		addNode(output);
		
		input_node  = input;
		output_node = output;
		
		input_node.loop  = self;
		output_node.loop = self;
		
		if(CLONING && is_instanceof(CLONING_GROUP, Node_Iterate_Filter_Inline)) {
			APPEND_MAP[? CLONING_GROUP.input_node.node_id]  = input;
			APPEND_MAP[? CLONING_GROUP.output_node.node_id] = output;
			
			ds_list_add(APPEND_LIST, input, output);
		}
	} #endregion
	
	static getIterationCount = function() { #region
		var _arr = input_node.inputs[| 0].getValue();
		return array_length(_arr);
	} #endregion
	
	static bypassNextNode = function() { #region
		return iterated < getIterationCount();
	} #endregion
	
	static getNextNodes = function() { #region
		LOG_BLOCK_START();	
		LOG_IF(global.FLAG.render == 1, "[outputNextNode] Get next node from inline iterate");
		
		resetRender();
		LOG_IF(global.FLAG.render == 1, $"Loop restart: iteration {iterated}");
		var _nodes = __nodeLeafList(nodes);
		array_push_unique(_nodes, input_node);
		iterated++;
		
		LOG_BLOCK_END();
		
		return _nodes;
	} #endregion
	
	static refreshMember = function() { #region
		ds_list_clear(nodes);
		
		for( var i = 0, n = array_length(attributes.members); i < n; i++ ) {
			if(!ds_map_exists(PROJECT.nodeMap, attributes.members[i])) {
				print($"Node not found {attributes.members[i]}");
				continue;
			}
			
			var _node = PROJECT.nodeMap[? attributes.members[i]];
			_node.inline_context = self;
			ds_list_add(nodes, _node);
			
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
	} #endregion
	
	static update = function() { #region
		if(input_node == noone || output_node == noone) {
			if(input_node)  input_node.destroy();
			if(output_node) output_node.destroy();
			destroy();
			return;
		}
		
		iterated = 0;
		output_node.outputs[| 0].setValue([]);
	} #endregion
	
}