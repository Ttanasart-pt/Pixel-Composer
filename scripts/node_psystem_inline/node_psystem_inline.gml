function Node_pSystem_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "Particle System";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	is_simulation      = true;
	update_on_frame    = true;
	
	is_root  = false;
	topoList = [];
	
	newInput(1, nodeValue_Dimension()).rejectArray();
	newInput(0, nodeValue_Bool( "Loop",       true )).rejectArray();
	newInput(2, nodeValue_Int(  "Pre-Render", -1   ));
	
	input_node_types   = [ Node_pSystem_Spawn,  Node_pSystem_from_Points  ];
	output_node_types  = [ Node_pSystem_Render, Node_pSystem_Render_Trail, Node_pSystem_Trail, Node_pSystem_Render_Path, 
	                       Node_pSystem_Triangulate ];
	input_display_list = [ 1, 
		[ "Loop", false, 0 ], 2 
	];
	
	////- Nodes
	
	loopable     = true;
	prerendering = false;
	dimension    = DEF_SURF;
	
	if(NODE_NEW_MANUAL) {
		var input  = nodeBuild("Node_pSystem_Spawn",  x,       y, self);
		var output = nodeBuild("Node_pSystem_Render", x + 256, y, self);
		
		output.inputs[0].setFrom(input.outputs[0]);
		
		addNode(input);
		addNode(output);
	}
	
	// static getNextNodes = function(checkLoop = false) { return __nodeLeafList(nodes); }
	
	static reset = function() {
		array_foreach(nodes, function(n) /*=>*/ { if(struct_has(n, "reset")) n.reset(); });
		
		var _loop = getInputData(0);
		var _prer = getInputData(2); if(_prer == -1) _prer = TOTAL_FRAMES - 1;
		if(!_loop) return;
		
		array_foreach(nodes, function(n) /*=>*/ { if(struct_has(n, "reset")) n.reset(); });
		
		if(!IS_PLAYING && !IS_FRAME_PROGRESS) {
			array_foreach(nodes, function(n) /*=>*/ { if(struct_has(n, "resetSeed")) n.resetSeed(); }); 
			return; 
		}
		
		prerendering = true;
		
		for(var i = TOTAL_FRAMES - _prer; i < TOTAL_FRAMES + 4; i++) {
			for( var j = 0, m = array_length(topoList); j < m; j++ ) {
				var node = topoList[j];
				if(!node.active) continue;
				
				if(node.preUpdate) node.preUpdate(i);
				node.getInputs(i);
				node.update(i);
			}
		}
		
		prerendering = false;
		array_foreach(nodes, function(n) /*=>*/ { if(struct_has(n, "resetSeed")) n.resetSeed(); });
	}
	
	static update = function() {
		dimension = inputs[1].getValue();
		
		if(IS_FIRST_FRAME) {
			if(IS_PLAYING) topoList = NodeListSort(nodes, project);
			reset();
		}
	}
	
}