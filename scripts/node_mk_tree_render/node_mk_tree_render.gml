function Node_MK_Tree_Render(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Render";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	
	newInput(0, nodeValue_Struct("Tree", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.dimension : [1,1]};
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		var _tree = getInputData(0);
		var _dim  = getDimension();
		
		var _outSurf = outputs[0].getValue();
		
		for( var i = 0, n = array_length(_tree); i < n; i++ ) _tree[i].root.drawn = false;
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			draw_set_color(c_white);
			draw_set_alpha(1);
			
			for( var i = 0, n = array_length(_tree); i < n; i++ ) {
				var _t = _tree[i];
				if(_t.root.drawn) continue;
				
				_t.root.drawn = true;
				_t.root.draw();
			}
		surface_reset_target();
		
		outputs[0].setValue(_outSurf);
	}
	
	
}