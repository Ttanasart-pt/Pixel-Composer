function Node_MK_Tree_Wiggle(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Wiggle";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	update_on_frame = true;
	setDrawIcon(s_node_mk_tree_wiggle);
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct("Tree", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Wiggle
	newInput( 4, nodeValue_Range( "Speed",     [1,1], true ));
	newInput( 2, nodeValue_Range( "Strength",  [4,4], true ));
	newInput( 3, nodeValue_Rotation_Random( "Direction", [0,0,360,0,0] ));
	// input 
	
	newOutput(0, nodeValue_Output("Tree", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 1, 0, 
		[ "Wiggle", false ], 4, 2, 3, 
	];
	
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
		
		var _seed = inline_context.seed + getInputData(1);
		
		var _tree = getInputData(0);
		
		var _sped = getInputData(4);
		var _strn = getInputData(2);
		var _angr = getInputData(3);
		
		random_set_seed(_seed);
		
		_tree = variable_clone(_tree);
		
		for( var i = 0, n = array_length(_tree); i < n; i++ ) {
			var _tr   = _tree[i];
			var _segs = _tr.segments;
			var _totl = _tr.totalLength;
			var _wstr = random_range(_strn[0], _strn[1]);
			var _ang  = rotation_random_eval(_angr);
			
			var _fspd = round(random_range(_sped[0], _sped[1]));
			
			var _inf  = (_wstr *  1) * sin(frac(random(1) + CURRENT_FRAME / TOTAL_FRAMES) * pi * 2 * (_fspd))     + 
			            (_wstr * .6) * sin(frac(random(1) + CURRENT_FRAME / TOTAL_FRAMES) * pi * 2 * (_fspd - 1)) + 
			            (_wstr * .3) * sin(frac(random(1) + CURRENT_FRAME / TOTAL_FRAMES) * pi * 2 * (_fspd - 2));
			            
			var _wx   = lengthdir_x(_inf, _ang);
			var _wy   = lengthdir_y(_inf, _ang);
			
			for( var j = 0, m = array_length(_segs); j < m; j++ ) {
				var _sg = _segs[j];
				var _ll = _tr.segmentLengths[j];
				
				_sg.x += _wx * _ll / _totl;
				_sg.y += _wy * _ll / _totl;
			}
			
			_tr.getLength();
		}
		
		outputs[0].setValue(_tree);
	}
	
}