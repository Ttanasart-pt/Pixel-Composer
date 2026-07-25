function Node_MK_Tree_Branch_Reroot(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Re-Root";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct( "Branch", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Scatter
	newInput( 2, nodeValue_Range( "Scatter",  [0,0] )).setCurvable(3, CURVE_DEF_11);
	// 4
	
	newOutput( 0, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ s_MKFX, 1, 0, 
		[ "Scatter", false ],  2,  3, 
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
			
			var _scat = getInputData( 2), scat_curve = inputs[2].attributes.curved? new curveMap(getInputData(3)) : undefined;
		#endregion
		
		var _len = array_safe_length(_bran);
		if(_len == 0) return;
		
		random_set_seed(_seed);
		
		var _branch = [];
		
		for( var i = 0; i < _len; i++ ) {
			var _br = _bran[i];
			if(!is(_br, __MK_Tree)) continue;
			
			var _par = _br.parent;
			if(is(_par, __MK_Tree)) 
				_par.clearCachePoints();
		}
		
		for( var i = 0; i < _len; i++ ) {
			var _br = _bran[i];
			if(!is(_br, __MK_Tree)) continue;
			
			var _par = _br.parent;
			var _pos = _br.rootPosition;
			
			if(!is(_par, __MK_Tree) || _pos <= 0) continue;
			
			var segs = _par.segments;
			var segl = _par.segmentLengths;
			var segr = _par.segmentRatio;
			var _rootPnt = _par.getPoints();
			
			if(array_empty(_rootPnt)) continue;
			
			_br.clearCachePoints();
			var _bpnt = _br.getPoints();
			if(array_empty(_bpnt)) continue;
			
			var _brot = _bpnt[0];
			var _rpnt = [[
				_rootPnt[0][0],
				_rootPnt[0][1],
				_rootPnt[0][2],
				
				_brot[3],
				_brot[4],
				_brot[5],
			]];
			
			var _bdir = array_length(_bpnt) > 1? sign(_bpnt[1][0] - _bpnt[0][0]) : 0;
			
			var _prvRat = 0;
			for( var j = 0, m = array_length(segr) - 1; j < m; j++ ) {
				var p0 = _rootPnt[j];
				var p1 = _rootPnt[j+1];
				var _segRat = segr[j];
				
				if(_pos >= _segRat) {
					array_push(_rpnt, [
						p1[0],
						p1[1],
						p1[2],
						
						_brot[3],
						_brot[4],
						_brot[5],
					]);
					
				} else {
					var _segMix = min((_pos - _prvRat) / (_segRat - _prvRat), 1)
					
					var pl = [
						lerp(p0[0], p1[0], _segMix), 
						lerp(p0[1], p1[1], _segMix), 
						lerp(p0[2], p1[2], _segMix), 
						
						_brot[3],
						_brot[4],
						_brot[5],
					];
					
					array_push(_rpnt, pl);
					break;
				}
				
				_prvRat = _segRat;
			}
			
			array_pop(_rpnt);
			array_pop(_rpnt);
			
			var _points = array_merge(_rpnt, _bpnt);
			var dx = random_range(_scat[0], _scat[1]) * _bdir;
			for( var j = 0, m = array_length(_points); j < m; j++ ) {
				var _prg = j / (m-1);
				_points[j][0] += dx * (scat_curve? scat_curve.get(_prg) : 1);
			}
			
			for( var j = 1, m = array_length(_points) - 1; j < m; j++ ) {
				_points[j][0] = (
					_points[j-1][0] + 
					_points[j  ][0] + 
					_points[j+1][0]
				) / 3;
				
				_points[j][1] = (
					_points[j-1][1] + 
					_points[j  ][1] + 
					_points[j+1][1]
				) / 3;
				
			}
			
			var newBr = _br.clone();
			newBr.setPoints(_points);
			
			array_push(_branch, newBr)
		}
		
		outputs[0].setValue(_branch);
	}
}