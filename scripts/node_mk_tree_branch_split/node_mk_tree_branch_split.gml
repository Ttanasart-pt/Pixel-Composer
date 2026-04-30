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
	
	////- =Segment
	newInput( 5, nodeValue_Range(  "Length",     [16,32]   ))
		.setCurvable(6, CURVE_DEF_11, "Over Branch", "curved", THEME.mk_tree_curve_branch );
	newInput( 7, nodeValue_Range(  "Segments",   [4,8]     ));
	
	////- =Direction
	newInput( 4, nodeValue_Range(   "Split Angle",   [15,30] ));
	newInput( 8, nodeValue_Range(   "Split Angle",   [15,30] ));
	newInput( 9, nodeValue_Range(   "Gravity",       [0,0], true    ))
		.setCurvable( 10, CURVE_DEF_11, "Over Length", "curved",        THEME.mk_tree_curve_length )
	
		////- =/Wiggle
	newInput(11, nodeValue_Range(   "Wiggle",    [0,0], true    ))
		.setCurvable( 12, CURVE_DEF_11, "Over Length", "curved",        THEME.mk_tree_curve_length )
	newInput(13, nodeValue_Range(   "Wig. Frequency",   [4,4], true ));
	newInput(14, nodeValue_Range(   "Wig. Phase",       [0,0], true ));
	
		////- =/Spiral
	newInput(15, nodeValue_Range(   "Frequency", [4,4], true ))
		.setCurvable(16, CURVE_DEF_11, "Over Length", "curved", THEME.mk_tree_curve_length );
	newInput(17, nodeValue_Range(   "Phase",     [0,0], true ));
	newInput(18, nodeValue_Range(   "Wave",      [0,0], true ))
		.setCurvable(19, CURVE_DEF_11, "Over Length", "curved", THEME.mk_tree_curve_length );
	newInput(20, nodeValue_Range(   "Curl",      [0,0], true ))
		.setCurvable(21, CURVE_DEF_11, "Over Length", "curved", THEME.mk_tree_curve_length );
	
	////- =Thickness
	newInput( 6, nodeValue_Range(    "Thickness", [2,2], true ))
		.setCurvable( 11, CURVE_DEF_11, "Over Length", "curved",        THEME.mk_tree_curve_length )
		.setCurvable( 36, CURVE_DEF_11, "Over Branch", "curved_branch", THEME.mk_tree_curve_branch )
	
	// 8
	
	newOutput(0, nodeValue_Output("Tree",     VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	newOutput(1, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	newOutput(2, nodeValue_Output("Trunk",    VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC).setVisible(false);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 1, 0, 
		[ "Position", false ],  2,  3, 
		[ "Split",    false ],  4,  
		[ "Segment",  false ],  5,  6,  7,  
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
			
			var _ang  = getInputData( 4);
			
			var _len  = getInputData( 5);
			var _lenC = getInputData( 6), curve_length = inputs[ 5].attributes.curved? new curveMap(_lenC)  : undefined;
			var _segs = getInputData( 7);
			
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
				
				_t.amount        = random_range(_segs[0], _segs[1]);
				// _t.texture       = _tex;
				_t.rootPosition  = _rat;
				_t.rootDirection = ori[2];
				_t.curvPosition  = _rat;
				_t.drawLine      = _line;
				
			}
		}
	}
}