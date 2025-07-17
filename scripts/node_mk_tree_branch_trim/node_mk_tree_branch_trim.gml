function Node_MK_Tree_Branch_Trim(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Trim Branch";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct("Branch", noone)).setVisible(true, true).setIcon(THEME.node_junction_mktree, COLORS.node_blend_mktree);
	
	////- =Trim
	newInput( 2, nodeValue_Surface( "Mask" ));
	// input 3
	
	newOutput(0, nodeValue_Output("Branch", VALUE_TYPE.struct, noone)).setIcon(THEME.node_junction_mktree, COLORS.node_blend_mktree);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 1, 0, 
		[ "Trim", false ], 2, 
	];
	
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
		
		var _seed = inline_context.seed + getInputData(1);
		random_set_seed(_seed);
		
		var _tree = getInputData(0);
		var _mask = getInputData(2);
		
		var _ntree = variable_clone(_tree);
		outputs[0].setValue(_ntree);
		
		if(!is_surface(_mask)) return;
		
		var _samp = new Surface_sampler(_mask);
		
		for( var i = 0, n = array_length(_ntree); i < n; i++ ) {
			var _tr   = _ntree[i];
			var _segs = _tr.segments;
			if(array_empty(_segs)) continue;
			
			var _rem = undefined;
			var ox, oy, nx, ny;
			ox = _segs[0].x;
			oy = _segs[0].y;
			
			for( var j = 1, m = array_length(_segs); j < m; j++ ) {
				var _sg = _segs[j];
				nx  = _sg.x;
				ny  = _sg.y;
				
				var smpC = _samp.getPixel(round(nx), round(ny));
				var samV = colorBrightness(smpC) * _color_get_alpha(smpC);
				
				if(random(1) >= samV) { 
					_rem = j; 
					break; 
				}
				
				ox = nx;
				oy = ny;
			}
			
			if(_rem != undefined) array_resize(_tr.segments, _rem);
			_tr.getLength();
		}
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_mk_tree_branch_trim, 0, bbox);
	}
}