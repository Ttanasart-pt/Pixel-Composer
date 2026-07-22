function Node_MK_Tree_Wiggle_Leaf(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Wiggle Leaves";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	update_on_frame = true;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct( "Leaves", noone)).setVisible(true, true).setCustomData(global.MKTREE_LEAVES_JUNC);
	
	////- =Wiggle
	newInput( 4, nodeValue_Range(   "Speed",     [1,1], true   ));
	newInput( 2, nodeValue_Range(   "Strength",  [4,4], true   ));
	newInput( 3, nodeValue_RotRand( "Direction", [0,0,360,0,0] ));
	// 5
	
	newOutput(0, nodeValue_Output("Tree", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_LEAVES_JUNC);
	
	input_display_list = [ s_MKFX, 1, 0, 
		[ "Wiggle", false ], 4, 2, 3, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		#region data
			var _seed = inline_context.seed + getInputData(1);
			
			var _leaf = getInputData(0);
			
			var _sped = getInputData(4);
			var _strn = getInputData(2);
			var _angr = getInputData(3);
			
			random_set_seed(_seed);
		#endregion
		
		var _outLeaf = outputs[0].getValue();
		
		for( var i = 0, n = array_length(_leaf); i < n; i++ ) {
			var _lf     = _leaf[i];
			_outLeaf[i] = _lf;
			
			if(!is(_lf, __MK_Tree_Leaf)) continue;
			
			var _wstr = random_range(_strn[0], _strn[1]);
			var _ang  = rotation_random_eval(_angr,, i);
			
			var _fspd = round(random_range(_sped[0], _sped[1]));
			
			var _inf  = (_wstr *  1) * sin(frac(random(1) + CURRENT_FRAME / TOTAL_FRAMES) * pi * 2 * (_fspd))     + 
			            (_wstr * .6) * sin(frac(random(1) + CURRENT_FRAME / TOTAL_FRAMES) * pi * 2 * (_fspd - 1)) + 
			            (_wstr * .3) * sin(frac(random(1) + CURRENT_FRAME / TOTAL_FRAMES) * pi * 2 * (_fspd - 2));
			
			_lf.dir += _inf;
			_lf.recalDir();
		}
		
		outputs[0].setValue(_outLeaf);
	}
	
}