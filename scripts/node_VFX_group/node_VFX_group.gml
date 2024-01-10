function VFX_PREVIEW_NODE() {
	if(!is_instanceof(group, Node_VFX_Group)) return self; 
	return group.getPreviewingNode();
}

function Node_VFX_Group(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "VFX";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	update_on_frame    = true;
	managedRenderOrder = true;
	
	topoList	 = ds_list_create();
	ungroupable  = false;
	preview_node = noone;
	allCached    = false;
	
	inputs[| 0] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true )
		.rejectArray();
	
	custom_input_index = ds_list_size(inputs);
	
	if(!LOADING && !APPENDING && !CLONING) { #region
		var input  = nodeBuild("Node_VFX_Spawner", -256, -32, self);
		var output = nodeBuild("Node_VFX_Renderer_Output", 256 + 32 * 5, -32, self);
		
		output.inputs[| output.input_fix_len + 1].setFrom(input.outputs[| 0]);
		preview_node = output;
	} #endregion
	
	static getNextNodes = function() { return allCached? getNextNodesExternal() : getNextNodesInternal(); } 
	
	insp2UpdateTooltip = "Clear cache";
	insp2UpdateIcon    = [ THEME.cache, 0, COLORS._main_icon ];
	
	static onInspector2Update = function() { #region
		for( var i = 0, n = ds_list_size(nodes); i < n; i++ ) {
			var node = nodes[| i];
			node.clearCache(); 
		}
	} #endregion
	
	static reset = function() { #region
		for( var i = 0, n = ds_list_size(nodes); i < n; i++ ) {
			var node = nodes[| i];
			if(!struct_has(node, "reset")) continue;
			node.reset();
		}
		
		var loop = getInputData(0);
		if(!loop) return;
		
		if(IS_PLAYING)
		for( var i = 0; i < TOTAL_FRAMES; i++ )
		for( var j = 0, m = ds_list_size(topoList); j < m; j++ ) {
			var node = topoList[| j];
			var _ins = instanceof(node);
			
			if(!string_pos("Node_VFX", _ins)) 
				continue;
			
			if(_ins == "Node_VFX_Renderer" || _ins == "Node_VFX_Renderer_Output") 
				continue;
			
			node.doUpdate(i);
		}
		
		for( var i = 0, n = ds_list_size(nodes); i < n; i++ ) {
			var node = nodes[| i];
			if(!struct_has(node, "resetSeed")) continue;
			node.resetSeed();
		}
	} #endregion
	
	static update = function() { #region
		if(CURRENT_FRAME == 0) 
			NodeListSort(topoList, nodes);
		
		allCached = true;
		for( var i = 0, n = ds_list_size(nodes); i < n; i++ ) {
			var node = nodes[| i];
			if(!node.recoverCache()) allCached = false;
		}
		
		if(!allCached && CURRENT_FRAME == 0)
			reset();
			
		if(allCached) {
			for( var i = 0, n = ds_list_size(nodes); i < n; i++ )
				nodes[| i].setRenderStatus(true);
			setRenderStatus(true);
		}
	} #endregion
	
	static ononDoubleClick = function(panel) { #region
		preview_node = noone;
		
		for( var i = 0, n = ds_list_size(nodes); i < n; i++ ) {
			var node = nodes[| i];
			if(is_instanceof(node, Node_VFX_Renderer_Output) || 
			   is_instanceof(node, Node_VFX_Renderer)) {
				   preview_node = node;
				   break;
			   }
		}
		
		PANEL_PREVIEW.setNodePreview(self);
	} #endregion
	
	getPreviewingNode = function() { return preview_node; }
}