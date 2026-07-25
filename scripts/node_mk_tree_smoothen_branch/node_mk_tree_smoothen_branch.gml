function Node_MK_Tree_Smoothen_Branch(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Smoothen Branch";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct( "Branch", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Smoothen
	newInput( 2, nodeValue_Int( "Smoothness", 1 ));
	// 3
	
	newOutput( 0, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ s_MKFX, 1, 0, 
		[ "Scatter", false ],  2,
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
			
			var _bran = getInputData( 0);
			
			var _smth = getInputData( 2);
		#endregion
		
		var _len = array_safe_length(_bran);
		if(_len == 0) return;
		
		random_set_seed(_seed);
		
		var _branch = [];
		
		for( var i = 0; i < _len; i++ ) {
			var _br = _bran[i];
			if(!is(_br, __MK_Tree)) continue;
			
			_br.clearCachePoints();
			var _bpnt = _br.getPoints();
			if(array_empty(_bpnt)) continue;
			
			var _points = [];
			for( var j = 0, n = array_length(_bpnt); j < n; j++ ) {
				var _p = _bpnt[j];
				
				var px = 0;
				var py = 0;
				
				var samp = 0;
				for( var k = -_smth; k <= _smth; k++ ) {
					var jk = clamp(j + k, 0, n-1);
					
					px += _bpnt[jk][0];
					py += _bpnt[jk][1];
					samp++;
				}
				
				px /= samp;
				py /= samp;
				
				_points[j] = [
					px,
					py,
					_p[2],
					
					_p[3],
					_p[4],
					_p[5],
				];
			}
			
			var newBr = _br.clone().setPoints(_points);
			
			array_push(_branch, newBr)
		}
		
		outputs[0].setValue(_branch);
	}
}