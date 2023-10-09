function VFX_PREVIEW_NODE() {
	if(!is_instanceof(group, Node_VFX_Group)) return self; 
	return group.getPreviewingNode();
}

function Node_VFX_Group(_x, _y, _group = noone) : Node_Collection(_x, _y, _group) constructor {
	name  = "VFX";
	color = COLORS.node_blend_vfx;
	icon  = THEME.vfx;
	
	topoList	 = ds_list_create();
	ungroupable  = false;
	preview_node = noone;
	
	inputs[| 0] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true )
		.rejectArray();
	
	custom_input_index = ds_list_size(inputs);
	
	if(!LOADING && !APPENDING && !CLONING) {
		var input  = nodeBuild("Node_VFX_Spawner", -256, -32, self);
		var output = nodeBuild("Node_VFX_Renderer_Output", 256 + 32 * 5, -32, self);
		
		output.inputs[| output.input_fix_len].setFrom(input.outputs[| 0]);
		preview_node = output;
	}
	
	static reset = function() {
		for( var i = 0, n = ds_list_size(nodes); i < n; i++ ) {
			var node = nodes[| i];
			if(is_instanceof(node, Node_VFX_Spawner_Base))
				node.reset();
		}
		
		var loop = getInputData(0);
		if(!loop) return;
		
		for( var i = 0; i < TOTAL_FRAMES; i++ )
		for( var j = 0, m = ds_list_size(topoList); j < m; j++ ) {
			var node = topoList[| j];
			if(is_instanceof(node, Node_VFX_Renderer_Output) ||
			   is_instanceof(node, Node_VFX_Renderer)) continue;
			
			node.update(i);
		}
		
		for( var i = 0, n = ds_list_size(nodes); i < n; i++ ) {
			var node = nodes[| i];
			if(!is_instanceof(node, Node_VFX_Spawner_Base)) continue;
				
			node.seed = node.getInputData(32);
		}
	}
	
	static update = function() {
		if(CURRENT_FRAME == 0) {
			NodeListSort(topoList, nodes);
			reset();
		}
	}
	
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
	} #endregion
	
	getPreviewingNode = function() { return preview_node; }
}