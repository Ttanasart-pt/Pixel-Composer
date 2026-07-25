function Node_MK_Tree_Wave_Branch(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Wave Branch";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct( "Branch", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Smoothen
	newInput( 2, nodeValue_Range(    "Frequency", [2,2], true ));
	newInput( 3, nodeValue_Range(    "Amplitude", [4,4], true )).setCurvable(4);
	newInput( 5, nodeValue_RotRange( "Phase",      ROTRAN_DEF_0 ));
	// 6
	
	newOutput( 0, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ s_MKFX, 1, 0, 
		[ "Scatter", false ],  2,  3,  4,  5, 
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
			
			var _freq = getInputData( 2);
			var _ampl = getInputData( 3);
			var _ampC = getInputData( 4), amp_curve = inputs[3].attributes.curved? new curveMap(_ampC) : undefined;
			var _phas = getInputData( 5);
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
			
			var freq = random_range(_freq[0], _freq[1]);
			var ampl = random_range(_ampl[0], _ampl[1]);
			
			var phas = rotation_random_eval(_phas);
			
			var _points = [];
			for( var j = 0, n = array_length(_bpnt); j < n; j++ ) {
				var _p = _bpnt[j];
				var _prg = j / (n-1);
				
				var px = _p[0];
				var py = _p[1];
				
				var ox = _bpnt[max(0,j-1)][0];
				var oy = _bpnt[max(0,j-1)][1];
				
				var nx = _bpnt[min(j+1,n-1)][0];
				var ny = _bpnt[min(j+1,n-1)][1];
				
				var dir = point_direction(ox, oy, nx, ny);
				var amp = ampl * (amp_curve? amp_curve.get(_prg) : 1);
				var wav = dsin(phas + _prg * 360 * freq) * amp;
				
				var dx = lengthdir_x(wav, dir + 90);
				var dy = lengthdir_y(wav, dir + 90);
				
				px += dx;
				py += dy;
				
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