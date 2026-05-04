function Node_MK_Tree_Branch_Split(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Split Branch";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon(s_node_mk_tree_branch);
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct( "Branch", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Position
	newInput( 2, nodeValue_SliRange( "Position", [.5,1] ));
	newInput( 3, nodeValue_Range(    "Amount",    [2,2] ));
	
	////- =Geometry
	newInput( 4, nodeValue_Range(  "Segments",   [4,8]     ));
	
	////- =Thickness
	newInput( 5, nodeValue_Range(    "Thickness", [2,2], true ))
		.setCurvable(  6, CURVE_DEF_11, "Over Length", "curved",        THEME.mk_tree_curve_length )
	// 7
	
	newOutput(0, nodeValue_Output("Tree",     VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	newOutput(1, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	newOutput(2, nodeValue_Output("Trunk",    VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC).setVisible(false);
	
	input_display_list = [ s_MKFX, 1, 0, 
		[ "Position",  false ],  2,  3, 
		[ "Geometry",  false ],  4, 
		[ "Thickness", false ],  5,  6, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _resT = outputs[preview_channel].getValue();
		
		if(is_array(_resT)) 
		for( var i = 0, n = array_length(_resT); i < n; i++ ) {
			var _t = _resT[i];
			if(is(_t, __MK_Tree)) _t.drawOverlay(_x, _y, _s);
		}
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		#region data
			var _seed = inline_context.seed + getInputData(1);
			var _gDir = inline_context.gravityDir;
			
			var _tree = getInputData( 0);
			
			var _oriR = getInputData( 2);
			var _amoR = getInputData( 3);
			
			var _seg  = getInputData( 4);
			
			var _len  = getInputData( 5);
			var _lenC = getInputData( 6), curve_length = inputs[ 5].attributes.curved? new curveMap(_lenC)  : undefined;
			
			random_set_seed(_seed);
		#endregion
		
		var _branches  = [];
		var _spawnIndx = 0;
		
		outputs[2].setValue(_tree);
		_tree = variable_clone(_tree);
		
		for( var i = 0, n = array_length(_tree); i < n; i++ ) {
			var _tr  = _tree[i];
			var _amo = irandom_range(_amoR[0], _amoR[1]);
			var _rat =  random_range(_oriR[0], _oriR[1]);
			
			var  ori  = [0,0,0];
			_tr.getPosition(_rat, ori);
			
			repeat(_amo) {
				var _t = new __MK_Tree();
				_t.seed = _seed + i;
				_t.root = _tr.root;
				_t.x = ori[0];
				_t.y = ori[1];
				
				_t.rootPosition  = _rat;
				_t.rootDirection = ori[2];
				_t.curvPosition  = _rat;
				_t.drawLine      = false;
				
			}
		}
	}
}