function Node_Iterate_Each_File_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "Loop File";
	color = COLORS.node_blend_loop;
	managedRenderOrder = true;
	
	is_root     = false;
	input_node  = noone;
	output_node = noone;
	
	input_node_types  = [ Node_Iterate_Each_File_Inline_Input  ];
	output_node_types = [ Node_Iterate_Each_File_Inline_Output ];
	
	newActiveInput(3);
	newInput(0, nodeValue_Path( "Path" )).setDisplay(VALUE_DISPLAY.path_load, { filter: "dir" }).setVisible(true, false);
	newInput(1, nodeValue_Text( "Extensions", ".png" ));
	newInput(2, nodeValue_Enum_Scroll( "Type",  0, [ "Surface", "Text" ] ));
	
	iteration_count  = 0;
	iterated         = 0;
	
	input_display_list = [ 3, 
		[ "Loop", false ], 0, 1, 2, 
	];
	
	activated = true;
	paths = [];
	
	if(!LOADING && !APPENDING) {
		var input  = nodeBuild("Node_Iterate_Each_File_Inline_Input",  x,       y, self);
		var output = nodeBuild("Node_Iterate_Each_File_Inline_Output", x + 256, y, self);
		
		if(!CLONING) output.inputs[0].setFrom(input.outputs[0]);
		
		addNode(input);
		addNode(output);
		
		input_node  = input;
		output_node = output;
		
		input_node.loop  = self;
		output_node.loop = self;
		
		if(CLONING && is(CLONING_GROUP, Node_Iterate_Each_File_Inline)) {
			APPEND_MAP[? CLONING_GROUP.input_node.node_id]  = input.node_id;
			APPEND_MAP[? CLONING_GROUP.output_node.node_id] = output.node_id;
			
			array_push(APPEND_LIST, input, output);
		}
	}
	
	static getIterationCount = function() /*=>*/ {return array_length(paths)};
	static bypassNextNode    = function() /*=>*/ {return iterated < getIterationCount()};
	
	static getNextNodes = function(checkLoop = false) {
		LOG_BLOCK_START	
		if(global.FLAG.render == 1) LOG("[outputNextNode] Get next node from inline iterate");
		
		resetRender();
		var _nodes = __nodeLeafList(nodes);
		if(global.FLAG.render == 1) LOG($"Loop restart: iteration {iterated} : leaf {_nodes}");
		
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
			
			if(is(_node, Node_Iterate_Each_File_Inline_Input)) {
				input_node = _node;
				input_node.loop = self;
			}
			
			if(is(_node, Node_Iterate_Each_File_Inline_Output)) {
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
		iterated = 0;
		
		var _path = inputs[0].getValue();
		var _ext  = inputs[1].getValue();
		var _type = inputs[2].getValue();
		activated = inputs[3].getValue();
		
		paths = [];
		if(!file_exists_empty(_path)) return;
		
		if(activated) paths = path_dir_get_files(_path, _ext, true);
	}
	
}