function Node_MK_Tree_Add_Branch(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Add Branch";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	update_on_frame = true;
	
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Struct("Tree", noone)).setVisible(true, true).setIcon(THEME.node_junction_mktree, COLORS.node_blend_mktree);
	
	newOutput(0, nodeValue_Output("Tree", VALUE_TYPE.struct, noone)).setIcon(THEME.node_junction_mktree, COLORS.node_blend_mktree);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 
		[ "Branches", false ], 
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue_Struct("Branch", noone)).setVisible(true, true)
			.setIcon(THEME.node_junction_mktree, COLORS.node_blend_mktree);
		
		array_push(input_display_list, inAmo);
		return inputs[index];
	}
	
	setDynamicInput(1, true, VALUE_TYPE.struct);
	dummy_input.setIcon(THEME.node_junction_mktree, COLORS.node_blend_mktree);
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _resT = outputs[0].getValue();
		if(is_array(_resT)) 
		for( var i = 0, n = array_length(_resT); i < n; i++ ) {
			var _t = _resT[i];
			if(is(_t, __MK_Tree)) _t.drawOverlay(_x, _y, _s);
		}
		
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		var _tree = getInputData(0);
		
		var _ntree = variable_clone(_tree);
		
		for( var i = 0, n = array_length(_ntree); i < n; i++ ) {
			var _tr = _ntree[i];
			
			for( var j = data_length; j < array_length(inputs); j++ ) {
				var br = getInputData(j);
				if(is_array(br)) array_append(_tr.children, br);
			}
		}
		
		outputs[0].setValue(_ntree);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_mk_tree_add_branch, 0, bbox);
	}
}