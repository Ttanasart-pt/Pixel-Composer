function VFX_PREVIEW_NODE()    { return is(group, Node_VFX_Group)? group.getPreviewingNode() : self; }
function VFX_PREVIEW_SURFACE() { return is(group, Node_VFX_Group)? group.getPreviewValues()  : self; }

function Node_VFX_Group(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "VFX";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	update_on_frame    = true;
	managedRenderOrder = true;
	
	topoList	 = [];
	ungroupable  = false;
	preview_node = noone;
	allCached    = false;
	
	newInput(0, nodeValue_Bool("Loop", self, true ))
		.rejectArray();
	
	custom_input_index = array_length(inputs);
	
	if(NODE_NEW_MANUAL) {
		var input  = nodeBuild("Node_VFX_Spawner", -256, -32, self);
		var output = nodeBuild("Node_VFX_Renderer_Output", 256 + 32 * 5, -32, self);
		
		output.inputs[output.input_fix_len + 1].setFrom(input.outputs[0]);
		preview_node = output;
	}
	
	static getNextNodes = function() { return allCached? getNextNodesExternal() : getNextNodesInternal(); } 
	
	setTrigger(2, "Clear cache", [ THEME.cache, 0, COLORS._main_icon ]);
	
	static onInspector2Update = function() {
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var node = nodes[i];
			node.clearCache(); 
		}
	}
	
	static reset = function() {
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var node = nodes[i];
			if(!struct_has(node, "reset")) continue;
			node.reset();
		}
		
		var loop = getInputData(0);
		if(!loop) return;
		
		if(IS_PLAYING)
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
		if(IS_FIRST_FRAME) 
			topoList = NodeListSort(nodes);
		
		allCached = true;
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var node = nodes[i];
			if(!node.recoverCache()) allCached = false;
		}
		
		if(!allCached && IS_FIRST_FRAME)
			reset();
			
		if(allCached) {
			for( var i = 0, n = array_length(nodes); i < n; i++ )
				nodes[i].setRenderStatus(true);
			setRenderStatus(true);
		}
	}
	
	static ononDoubleClick = function(panel) {
		preview_node = noone;
		
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var node = nodes[i];
			if(is(node, Node_VFX_Renderer_Output) || is(node, Node_VFX_Renderer)) {
			   preview_node = node;
			   break;
		   }
		}
		
		PANEL_PREVIEW.setNodePreview(self);
	}
	
	getPreviewingNode = function() { return preview_node; }
	getPreviewValues  = function() { return preview_node.getPreviewValues(); }
}