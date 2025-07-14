function Node_MK_Tree_Grow(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Grow";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	update_on_frame = true;
	
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct("Tree", noone)).setVisible(true, true).setIcon(THEME.node_junction_mktree, COLORS.node_blend_mktree);
	
	////- =Grow
	newInput( 2, nodeValue_Slider( "Progress",         1.5, [-1, 4, .001] ));
	newInput( 5, nodeValue_Range(  "Branch Speed",     [1,1], true ));
	newInput( 3, nodeValue_Range(  "Thickness Effect", [0,0], true ));
	
	////- =Leaf
	newInput( 6, nodeValue_Range(  "Leaf Delay",       [0,0], true ));
	newInput( 4, nodeValue_Range(  "Leaf Falloff",     [4,4], true ));
	// input 7
	
	newOutput(0, nodeValue_Output("Tree", VALUE_TYPE.struct, noone)).setIcon(THEME.node_junction_mktree, COLORS.node_blend_mktree);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 1, 0, 
		[ "Grow", false ], 2, 5, 3, 
		[ "Leaf", false ], 6, 4, 
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
		
		var _grow = getInputData(2);
		var _rtSc = getInputData(5);
		var _falB = getInputData(3);
		
		var _delL = getInputData(6);
		var _falL = getInputData(4);
		
		var _ntree = variable_clone(_tree);
		
		for( var i = 0, n = array_length(_ntree); i < n; i++ ) {
			var _tr   = _ntree[i];
			var _segs = _tr.segments;
			var _rats = _tr.segmentRatio;
			var _lens = _tr.segmentLengths;
			var _tlen = _tr.totalLength;
			
			var _baseSpeed = random_range(_rtSc[0], _rtSc[1]);
			var _growShift = _tr.growShift;
			
			var _tgro  = _grow - _tr.rootPosition * _baseSpeed + _growShift;
			    _tgro  = max(0, _tgro);
			
			var _tfalB = random_range(_falB[0], _falB[1]);
			var _tfalL = random_range(_falL[0], _falL[1]);
			var _tdelL = random_range(_delL[0], _delL[1]);
			
			var _len  = _tlen * _tgro;
			var _rem  = undefined;
			
			for( var j = 1, m = array_length(_segs); j < m; j++ ) {
				var _sg0 = _segs[j-1];
				var _sg1 = _segs[j];
				var _ll  = _lens[j];
				
				_sg1.thickness *= lerp(1, _tgro, _tfalB);
				if(_ll < _len) { _len -= _ll; continue; }
				
				var _dir = point_direction(_sg0.x, _sg0.y, _sg1.x, _sg1.y);
				_sg1.x = _sg0.x + lengthdir_x(_len, _dir);
				_sg1.y = _sg0.y + lengthdir_y(_len, _dir);
				
				_rem = j;
				break;
			}
			
			if(_rem != undefined) array_resize(_tr.segments, _rem + 1);
			_tr.getLength();
			
			var _lgro = _tgro - _tdelL;
			
			for( var j = 0, m = array_length(_tr.leaves); j < m; j++ ) {
				var _l  = _tr.leaves[j];
				var _dr = (_lgro - _l.rootPosition + _l.growShift) * _tlen / _tfalL;
				    _dr = clamp(_dr, 0, 1);
				_l.scale = _dr;
			}
		}
		
		outputs[0].setValue(_ntree);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_mk_tree_grow, 0, bbox);
	}
}