function Node_pSystem_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "Particle System";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	is_simulation      = true;
	update_on_frame    = true;
	managedRenderOrder = true;
	
	is_root  = false;
	topoList = [];
	
	newInput(1, nodeValue_Dimension()).rejectArray();
	newInput(0, nodeValue_Bool( "Loop",       true )).rejectArray();
	newInput(2, nodeValue_Int(  "Pre-Render", -1   ));
	
	input_node_types   = [ Node_pSystem_Spawn  ];
	output_node_types  = [ Node_pSystem_Render, Node_pSystem_Render_Trail, Node_pSystem_Trail, Node_pSystem_Triangulate ];
	input_display_list = [ 1, 
		[ "Loop", false, 0 ], 2 
	];
	
	////- Nodes
	
	loopable     = true;
	prerendering = false;
	dimension    = DEF_SURF;
	
	if(NODE_NEW_MANUAL) {
		var input  = nodeBuild("Node_pSystem_Spawn",  x,  y,      self);
		var output = nodeBuild("Node_pSystem_Render", x + 256, y, self);
		
		output.inputs[0].setFrom(input.outputs[0]);
		
		addNode(input);
		addNode(output);
	}
	
	static getNextNodes = function(checkLoop = false) { return __nodeLeafList(nodes); }
	
	static reset = function() {
		array_foreach(nodes, function(n) /*=>*/ { if(struct_has(n, "reset")) n.reset(); });
		
		var _loop = getInputData(0);
		var _prer = getInputData(2); if(_prer == -1) _prer = TOTAL_FRAMES;
		if(!_loop) return;
		
		array_foreach(nodes, function(n) /*=>*/ { if(struct_has(n, "reset")) n.reset(); });
		
		if(!IS_PLAYING) { array_foreach(nodes, function(n) /*=>*/ { if(struct_has(n, "resetSeed")) n.resetSeed(); }); return; }
		
		prerendering = true;
		// var _t = get_timer(); print($"Pre-rendering started");
		
		for(var i = TOTAL_FRAMES - _prer; i < TOTAL_FRAMES; i++) {
			for( var j = 0, m = array_length(topoList); j < m; j++ ) {
				var node = topoList[j];
				if(!node.active) continue;
				
				node.doUpdate(i);
			}
		}
		
		prerendering = false;
		array_foreach(nodes, function(n) /*=>*/ { if(struct_has(n, "resetSeed")) n.resetSeed(); });
		// print($"Pre-rendering completed in {(get_timer() - _t) / 1000}ms");
	}
	
	static update = function() {
		dimension = inputs[1].getValue();
		
		if(IS_FIRST_FRAME) {
			if(IS_PLAYING) topoList = NodeListSort(nodes);
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