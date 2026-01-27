function Node_MK_Tree_Grow(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tree Grow";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	update_on_frame = true;
	setDrawIcon(s_node_mk_tree_grow);
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct("Tree", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	newInput( 2, nodeValue_Slider( "Progress",         1.5, [-1, 4, .001] ));
	
	////- =Branch
	newInput( 5, nodeValue_Range(  "Branch Speed",     [1,1], true ));
	newInput( 3, nodeValue_Range(  "Thickness Effect", [0,0], true ));
	
	////- =Leaves
	newInput( 6, nodeValue_Range(  "Leaves Delay",     [0,0], true ));
	newInput( 4, nodeValue_Range(  "Leaves Falloff",   [4,4], true ))
		.setCurvable( 7, CURVE_DEF_01, "Falloff" );
	newInput( 8, nodeValue_Range(  "Whorled Delay",    [0,0], true ))
		.setCurvable( 9, CURVE_DEF_01, "Falloff" );
	// input 10
	
	newOutput(0, nodeValue_Output("Tree", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 1, 0, 2, 
		[ "Branch", false ], 5, 3, 
		[ "Leaves", false ], 6, 4, 7, 8, 9, 
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
		
		#region data
			var _seed  = getInputData( 1) + inline_context.seed;
			random_set_seed(_seed);
			
			var _tree  = getInputData( 0);
			var _grow  = getInputData( 2);
			
			var _rtSc  = getInputData( 5);
			var _falB  = getInputData( 3);
			
			var _delL  = getInputData( 6);
			
			var _falL  = getInputData( 4);
			var _falLC = getInputData( 7), curve_fallL = inputs[ 4].attributes.curved? new curveMap(_falLC) : undefined;
			
			var _whoL  = getInputData( 8);
			var _whoLC = getInputData( 9), curve_whorl = inputs[ 8].attributes.curved? new curveMap(_whoLC) : undefined;
		#endregion
			
		var _ntree = variable_clone(_tree);
		
		for( var i = 0, n = array_length(_ntree); i < n; i++ ) {
			var _tr = _ntree[i];
			
			var _tdelL = random_range(_delL[0], _delL[1]);
			var _tfalL = random_range(_falL[0], _falL[1]);
			var _twhoL = random_range(_whoL[0], _whoL[1]);
			
			if(is(_tr, __MK_Tree_Leaf)) { 
				var sc  = (_grow - _tr.rootPosition + _tr.growShift) * _tr.root.totalLength / _tfalL;
				    sc += _tdelL;
				    sc += _twhoL * (curve_whorl? curve_whorl.get(_tr.whorlIndex) : _tr.whorlIndex);
				    sc  = curve_fallL? curve_fallL.get(sc) : sc;
				    sc  = clamp(sc, 0, 1);
				    
				_tr.scale = sc;
				continue; 
			}
			
			var _tfalB = random_range(_falB[0], _falB[1]);
			
			var _segs = _tr.segments;
			var _rats = _tr.segmentRatio;
			var _lens = _tr.segmentLengths;
			var _tlen = _tr.totalLength;
			
			var _baseSpeed = random_range(_rtSc[0], _rtSc[1]);
			var _growShift = _tr.growShift;
			
			var _tgro  = _grow - _tr.rootPosition * _baseSpeed + _growShift;
			    _tgro  = max(0, _tgro);
			
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
				var sc = (_lgro - _l.rootPosition + _l.growShift) * _tlen / _tfalL;
				    sc += _twhoL * (curve_whorl? curve_whorl.get(_l.whorlIndex) : _l.whorlIndex);
					sc = curve_fallL? curve_fallL.get(sc) : sc;
				    sc = clamp(sc, 0, 1);
				    
				_l.scale = sc;
			}
		}
		
		outputs[0].setValue(_ntree);
	}
	
}