function Node_VFX_Group_Inline(_x, _y, _group = noone) : Node_Collection_Inline(_x, _y, _group) constructor {
	name  = "VFX";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	
	inputs[| 0] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true )
		.rejectArray();
	
	topoList	 = ds_list_create();
	
	update_on_frame    = true;
	managedRenderOrder = true;
	
	if(!LOADING && !APPENDING && !CLONING) { #region
		var input  = nodeBuild("Node_VFX_Spawner",  x,       y);
		var output = nodeBuild("Node_VFX_Renderer", x + 256, y);
		
		output.inputs[| output.input_fix_len + 1].setFrom(input.outputs[| 0]);
		
		addNode(input);
		addNode(output);
	} #endregion
	
	static getNextNodes = function() { #region
		return __nodeLeafList(nodes);
	} #endregion
	
	static reset = function() { #region
		for( var i = 0, n = ds_list_size(nodes); i < n; i++ ) {
			var node = nodes[| i];
			if(!struct_has(node, "reset")) continue;
			node.reset();
		}
		
		var loop = getInputData(0);
		if(!loop) return;
		
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
		if(CURRENT_FRAME == 0) {
			NodeListSort(topoList, nodes);
			reset();
		}
	} #endregion
	
}