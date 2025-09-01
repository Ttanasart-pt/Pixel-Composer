function Node_VFX_Group_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "VFX";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	
	is_root  = false;
	topoList = [];
	
	newInput(1, nodeValue_Dimension()).rejectArray();
	newInput(0, nodeValue_Bool( "Loop",       true )).rejectArray();
	newInput(2, nodeValue_Int(  "Pre-Render", -1   ));
	
	output_node_types  = [ Node_VFX_Renderer ];
	input_display_list = [ 1, 
		[ "Loop", false, 0 ], 2 
	];
	
	////- Nodes
	
	is_simulation      = true;
	update_on_frame    = true;
	managedRenderOrder = true;
	loopable           = true;
	
	dimension  = DEF_SURF;
	
	if(NODE_NEW_MANUAL) {
		var input  = nodeBuild("Node_VFX_Spawner",  x,       y, self);
		var output = nodeBuild("Node_VFX_Renderer", x + 256, y, self);
		
		output.dummy_input.setFrom(input.outputs[0]);
		
		addNode(input);
		addNode(output);
	}
	
	static getNextNodes = function(checkLoop = false) { return __nodeLeafList(nodes); }
	
	static reset = function() {
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var node = nodes[i];
			if(!struct_has(node, "reset")) continue;
			node.reset();
		}
		
		var _loop = getInputData(0);
		var _prer = getInputData(2); if(_prer == -1) _prer = TOTAL_FRAMES;
		if(!_loop) return;
		
		for(var i = TOTAL_FRAMES - _prer; i < TOTAL_FRAMES; i++) {
			for( var j = 0, m = array_length(topoList); j < m; j++ ) {
				var node = topoList[j];
				var _ins = instanceof(node);
				
				if(!string_pos("Node_VFX", _ins)) continue;
				if(is(node, Node_VFX_Renderer))   continue;
				
				node.doUpdate(i);
			}
		}
		
		array_foreach(nodes, function(n) /*=>*/ { if(struct_has(n, "resetSeed")) n.resetSeed(); });
		
	}
	
	static update = function() {
		dimension = inputs[1].getValue();
		
		if(IS_FIRST_FRAME) {
			topoList = NodeListSort(nodes);
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