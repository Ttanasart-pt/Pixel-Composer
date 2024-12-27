function Node_VFX_Group_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "VFX";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	
	is_root  = false;
	topoList = [];
	
	newInput(0, nodeValue_Bool("Loop", self, true ))
		.rejectArray();
	
	is_simulation      = true;
	update_on_frame    = true;
	managedRenderOrder = true;
	
	prev_nodes = [];
	
	if(NODE_NEW_MANUAL) {
		var input  = nodeBuild("Node_VFX_Spawner",  x,       y);
		var output = nodeBuild("Node_VFX_Renderer", x + 256, y);
		
		output.dummy_input.setFrom(input.outputs[0]);
		
		addNode(input);
		addNode(output);
	}
	
	static getPreviousNodes = function() { onGetPreviousNodes(prev_nodes); return prev_nodes; }
	
	static onRemoveNode = function(node) { node.in_VFX = noone; }
	static onAddNode    = function(node) { node.in_VFX = self;  }
	
	static getNextNodes = function(checkLoop = false) { return __nodeLeafList(nodes); }
	
	static reset = function() {
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var node = nodes[i];
			if(!struct_has(node, "reset")) continue;
			node.reset();
		}
		
		var loop = getInputData(0);
		if(!loop) return;
		
		for( var i = 0; i < TOTAL_FRAMES; i++ )
		for( var j = 0, m = array_length(topoList); j < m; j++ ) {
			var node = topoList[j];
			var _ins = instanceof(node);
			
			if(!string_pos("Node_VFX", _ins)) 
				continue;
			
			if(_ins == "Node_VFX_Renderer" || _ins == "Node_VFX_Renderer_Output") 
				continue;
			
			node.doUpdate(i);
		}
		
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var node = nodes[i];
			if(!struct_has(node, "resetSeed")) continue;
			node.resetSeed();
		}
	}
	
	static update = function() {
		if(!IS_FIRST_FRAME) return;
		
		topoList = NodeListSort(nodes);
		reset();
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