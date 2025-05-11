function Node_Iterate_Sort_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "Sort Array";
	color = COLORS.node_blend_loop;
	
	is_root  = false;
	topoList = [];
	
	input_node  = noone;
	output_node = noone;
	
	toSort = true;
	
	input_node_type  = [ Node_Iterator_Sort_Inline_Input ];
	output_node_types = [ Node_Iterator_Sort_Inline_Output ];
	iterated         = 0;
	
	if(!LOADING && !APPENDING) {
		var input  = nodeBuild("Node_Iterator_Sort_Inline_Input",  x,       y, self);
		var output = nodeBuild("Node_Iterator_Sort_Inline_Output", x + 256, y, self);
		
		addNode(input);
		addNode(output);
		
		input_node  = input;
		output_node = output;
		
		input_node.loop  = self;
		output_node.loop = self;
		
		if(CLONING && is_instanceof(CLONING_GROUP, Node_Iterate_Sort_Inline)) {
			APPEND_MAP[? CLONING_GROUP.input_node.node_id]  = input.node_id;
			APPEND_MAP[? CLONING_GROUP.output_node.node_id] = output.node_id;
			
			array_push(APPEND_LIST, input, output);
		}
	}
	
	static isActiveDynamic = function(frame = CURRENT_FRAME) {
		for( var i = 0, n = array_length(nodes); i < n; i++ )
			if(nodes[i].isActiveDynamic(frame)) return true;
		
		return false;
	}
	
	static getNextNodes = function(checkLoop = false) {
		return output_node.getNextNodes();
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
			
			if(is_instanceof(_node, Node_Iterator_Sort_Inline_Input)) {
				input_node = _node;
				input_node.loop = self;
			}
			
			if(is_instanceof(_node, Node_Iterator_Sort_Inline_Output)) {
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
	
	static update = function(frame = CURRENT_FRAME) {
		if(input_node == noone || output_node == noone) {
			if(input_node)  input_node.destroy();
			if(output_node) output_node.destroy();
			destroy();
			return;
		}
		
		if(IS_FIRST_FRAME) toSort = true;
		if(toSort) topoList = NodeListSort(nodes);
		toSort = false;
		
		input_node.startSort = true;
		//sortArray();
	}
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	static swap = function(arr, a, b) {
		var temp = arr[a];
		arr[@ a] = arr[b];
		arr[@ b] = temp;
	}
	
	static compareValue = function(val1, val2) {
		input_node.outputs[0].setValue(val1,,, false);
		input_node.outputs[1].setValue(val2,,, false);
		
		resetRender(true);
		RenderList(topoList);
		
		var res = output_node.inputs[0].getValue();
		//print($"Comparing value {val1}, {val2} > [{res}]");
		
		return res;
	}
	
	static partition = function(arr, low, high) {
		var pv = arr[high]; 
		var i  = low - 1;
		
		for(var j = low; j < high; j++) {
			if(compareValue(arr[j], pv)) continue;
			
			i++;
			swap(arr, i, j);
		}
		
		swap(arr, i + 1, high);
		return i + 1;
	}
	
	static quickSort = function(arr, low, high) {
		if(low >= high) return;
		
		var p = partition(arr, low, high);
		
		quickSort(arr, low, p - 1);
		quickSort(arr, p + 1, high);
	}
	
	static sortArray = function() {
		iterated = 0;
		loop_start_time = get_timer();
		
		var _frj = input_node.inputs[0].value_from;
		var type = _frj == noone? VALUE_TYPE.any : _frj.type;
		
		input_node.inputs[0].setType(type);
		input_node.outputs[0].setType(type);
		input_node.outputs[1].setType(type);
		
		output_node.outputs[0].setType(type);
		
		if(input_node.inputs[0].value_from == noone) return;
		
		var arrIn  = input_node.inputs[0].getValue();
		var arrOut = output_node.outputs[0].getValue();
		
		arrOut = array_clone(arrIn);
		
		quickSort(arrOut, 0, array_length(arrOut) - 1);
		output_node.outputs[0].setValue(arrOut);
	}
	
}