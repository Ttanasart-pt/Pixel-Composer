function Node_MK_Tree_Add_Leaf(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Add Leaf";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	update_on_frame = true;
	setDrawIcon(s_node_mk_tree_add_leaf);
	setDimension(96, 48);
	
	////- =Leaves
	newInput( 0, nodeValue_Struct( "Tree",  noone )).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	newInput( 1, nodeValue_Int(    "Order", 0     ));
	// 2
	
	newOutput(0, nodeValue_Output("Tree", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 1, 
		[ "Leaves", false ], 
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue_Struct("Leaves", noone)).setVisible(true, true).setCustomData(global.MKTREE_LEAVES_JUNC);
		array_push(input_display_list, inAmo);
		
		return inputs[index];
	}
	
	setDynamicInput(1, true, VALUE_TYPE.struct);
	dummy_input.setCustomData(global.MKTREE_LEAVES_JUNC);
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : [1,1]};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _resT = outputs[0].getValue();
		if(is_array(_resT)) 
		for( var i = 0, n = array_length(_resT); i < n; i++ ) {
			var _t = _resT[i];
			if(is(_t, __MK_Tree)) _t.drawOverlay(_x, _y, _s);
		}
		
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		#region data
			var _tree  = getInputData(0);
			var _ordr  = getInputData(1);
			var _ntree = variable_clone(_tree);
			
			outputs[0].setValue(_ntree);
		#endregion
		
		if(!is_array(_ntree) || array_empty(_ntree)) return;
		array_foreach(_ntree, function(t,i) /*=>*/ { if(t.root) t.root.drawn = false; })
		
		var _tr = _ntree;
		if(is_array(_tr)) { 
			var _len = array_length(_tr);
			if(_ordr < 0) _ordr = _len + _ordr;
			_tr = array_safe_get(_tr, clamp(_ordr, 0, _len - 1));
		}
			
		if(is(_tr, __MK_Tree)) {
			for( var j = data_length, m = array_length(inputs); j < m; j++ ) {
				var lf = getInputData(j);
				if(is_array(lf)) array_append(_tr.leaves, lf);
			}
		}
		
	}
	
}