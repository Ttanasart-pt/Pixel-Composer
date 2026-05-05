function Node_MK_Tree_Leaf_to_Points(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Leaves to Points";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	parameters.inline_draw_output = true;
	
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Leaves
	newInput( 0, nodeValue_Struct( "Leaves")).setVisible(true, true).setCustomData(global.MKTREE_LEAVES_JUNC);
	// 1
	
	newOutput(0, nodeValue_Output("Points", VALUE_TYPE.float, [])).setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [ 
		[ "Leaves",   false ],  0, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static update = function(_frame = CURRENT_FRAME) {
		#region data
			var _leav = getInputData( 0);
			
			if(!is_array(_leav)) return;
		#endregion
		
		var _len  = array_length(_leav);
		var _pnts = array_create(_len);
		var _ind  = 0;
		
		for( var i = 0; i < _len; i++ ) {
			var _l = _leav[i];
			if(!is(_l, __MK_Tree_Leaf)) return;
			
			_pnts[_ind++] = [_l.x, _l.y];
		}
		
		array_resize(_pnts, _ind);
		outputs[0].setValue(_pnts);
	}
}
