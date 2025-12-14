function Node_pSystem_3D_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "3D Particle System";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	is_simulation      = true;
	// update_on_frame    = true;
	// managedRenderOrder = true;
	
	is_root  = false;
	topoList = [];
	
	newInput(0, nodeValue_Bool( "Loop",       true )).rejectArray();
	newInput(1, nodeValue_Int(  "Pre-Render", -1   ));
	
	input_node_types   = [ Node_pSystem_3D_Spawn, Node_pSystem_3D_from_Points  ];
	output_node_types  = [ Node_pSystem_3D_Render_Model, Node_pSystem_3D_Trail ];
	input_display_list = [ 
		[ "Loop", false, 0 ], 1,  
	];
	
	////- Nodes
	
	loopable     = true;
	prerendering = false;
	
	if(NODE_NEW_MANUAL) {
		var input  = nodeBuild("Node_pSystem_3D_Spawn", x, y, self);
		var output = nodeBuild("Node_pSystem_3D_Render_Model", x + 256, y, self);
		
		output.inputs[0].setFrom(input.outputs[0]);
		
		addNode(input);
		addNode(output);
	}
	
	static getNextNodes = function(checkLoop = false) { return __nodeLeafList(nodes); }
	
	static reset = function() {
		array_foreach(nodes, function(n) /*=>*/ { if(struct_has(n, "reset")) n.reset(); });
		
		var _loop = getInputData(0);
		var _prer = getInputData(1); if(_prer == -1) _prer = TOTAL_FRAMES;
		if(!_loop) return;
		
		array_foreach(nodes, function(n) /*=>*/ { if(struct_has(n, "reset")) n.reset(); });
		
		if(!IS_PLAYING) { array_foreach(nodes, function(n) /*=>*/ { if(struct_has(n, "resetSeed")) n.resetSeed(); }); return; }
		
		prerendering = true;
		
		for(var i = TOTAL_FRAMES - _prer; i < TOTAL_FRAMES; i++) {
			for( var j = 0, m = array_length(topoList); j < m; j++ ) {
				var node = topoList[j];
				if(!node.active) continue;
				
				node.doUpdate(i);
			}
		}
		
		prerendering = false;
		array_foreach(nodes, function(n) /*=>*/ { if(struct_has(n, "resetSeed")) n.resetSeed(); });
	}
	
	static update = function() {
		if(IS_FIRST_FRAME) {
			if(IS_PLAYING) topoList = NodeListSort(nodes, project);
			reset();
		}
	}
	
	static getPreviewingNode = function() {
		for( var i = 0, n = array_length(nodes); i < n; i++ ) 
			if(is(nodes[i], Node_VFX_Renderer)) return nodes[i];
		return self;
	}
	
	static getPreviewValues = function() {
		for( var i = 0, n = array_length(nodes); i < n; i++ )
			if(is(nodes[i], Node_VFX_Renderer)) return nodes[i].getPreviewValues();
		return noone;
	}
	
}