function Node_MK_Tree_Ground_Branch(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Ground Branch";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct( "Branch", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Ground
	newInput( 7, nodeValue_Range(  "Offset", [0,0], true ));
	newInput( 2, nodeValue_Range(  "Spread", [0,1]       )).setCurvable(3);
	
	////- =Modulate Thickness
	newInput( 4, nodeValue_Bool(   "Modulate Thickness", false ));
	newInput( 6, nodeValue_Range(  "Range",      [0,1]         ));
	newInput( 5, nodeValue_Curve(  "Thickness",  CURVE_DEF_01  ));
	// 8
	
	newOutput( 0, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ s_MKFX, 1, 0, 
		[ "Scatter",            false    ],  7,  2,  3,  
		[ "Modulate Thickness", false, 4 ],  6,  5, 
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
			
			var _offs = getInputData( 7);
			var _sprd = getInputData( 2);
			var _sprC = getInputData( 3), spr_curve = inputs[2].attributes.curved? new curveMap(_sprC) : undefined;
			
			var _thk  = getInputData( 4);
			var _thkR = getInputData( 6);
			var _thkC = getInputData( 5), thk_curve = new curveMap(_thkC);
		#endregion
		
		var _len = array_safe_length(_bran);
		if(_len == 0) return;
		
		random_set_seed(_seed);
		
		var _dim = getDimension();
		var _branch = [];
		
		for( var i = 0; i < _len; i++ ) {
			var _br = _bran[i];
			if(!is(_br, __MK_Tree)) continue;
			
			_br.clearCachePoints();
			var _bpnt = _br.getPoints();
			if(array_empty(_bpnt)) continue;
			
			var _points = [];
			var _offset = [];
			var n = array_length(_bpnt);
			
			var sprd = random_range(_sprd[0], _sprd[1]);
			var offs = random_range(_offs[0], _offs[1]);
			
			var gy = _dim[1] - offs;
			
			for( var j = n-2; j >= 0; j-- ) {
				var _op = _bpnt[j+1];
				var _p  = _bpnt[j];
				var _prg = j / (n-1);
				
				var px = _p[0];
				var py = _p[1];
				
				var dy = max(0, py - gy);
				var sx = sign(px - _op[0]);
				
				py = min(py, gy);
				px = _op[0] + sx * dy * sprd;
				
				_points[j] = [
					px,
					py,
					_p[2],
					
					_p[3],
					_p[4],
					_p[5],
				];
				
				_offset[j] = dy;
			}
			
			var maxOff = array_max(_offset);
			for( var j = 0; j < n-1; j++ ) {
				var _of = maxOff - _offset[j];
				var _prg = j / (n-1);
				
				if(spr_curve)
					_of *= spr_curve.get(_prg);
				
				_points[j][1] -= _of;
			}
			
			if(_thk) {
				for( var j = 0; j < n-1; j++ ) {
					var _prg = j / (n-1);
					    _prg = (_prg - _thkR[0]) / (_thkR[1] - _thkR[0]);
					
					_points[j][2] *= thk_curve.get(_prg);
				}
				
			}
			
			var newBr = _br.clone().setPoints(_points);
			
			array_push(_branch, newBr)
		}
		
		outputs[0].setValue(_branch);
	}
}