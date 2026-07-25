function Node_MK_Tree_Spiral_Branch(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Spiral Branch";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct( "Branch", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Smoothen
	newInput( 2, nodeValue_Range(    "Amplitude", [4,4], true )).setCurvable(3);
	newInput( 4, nodeValue_EButton(  "Flip",       0, [ "None", "Random", "Starting Angle" ] ));
	// 5
	
	newOutput( 0, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ s_MKFX, 1, 0, 
		[ "Scatter", false ],  2,  3,  4, 
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
			
			var _ampl = getInputData( 2);
			var _ampC = getInputData( 3), amp_curve = inputs[2].attributes.curved? new curveMap(_ampC) : undefined;
			var _flip = getInputData( 4);
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
			
			var ampl  = random_range(_ampl[0], _ampl[1]);
			
			if(_flip == 1)
			    ampl *= choose(-1, 1);
			
			var _points = [];
			var _sprang = 0;
			var _dirr   = 0;
			
			var ox, oy, nx, ny;
			var oa = undefined, na;
			
			for( var j = 0, n = array_length(_bpnt); j < n; j++ ) {
				var _p  = _bpnt[j];
				var _prg = j / (n-1);
				
				nx = _p[0];
				ny = _p[1];
				
				if(j) {
					var op = _bpnt[j-1];
					
					var dis  = point_distance( op[0], op[1], _p[0], _p[1]);
					var dir  = point_direction(op[0], op[1], _p[0], _p[1]);
					
					na = dir;
					if(oa != undefined) {
						var da = angle_difference(na, oa);
						if(abs(da) > 1) _dirr = sign(da);
					}
				    
				    dir += _sprang;
					var dx = lengthdir_x(dis, dir);
					var dy = lengthdir_y(dis, dir);
					
					var amp = ampl * (amp_curve? amp_curve.get(_prg) : 1);
					if(_flip == 2) amp *= _dirr;
					
					_sprang += amp
			
					var px = ox + dx;
					var py = oy + dy;
					
					nx = px;
					ny = py;
					oa = na;
					
					_points[j] = [
						px,
						py,
						_p[2],
						
						_p[3],
						_p[4],
						_p[5],
					];
					
				} else {
					_points[0] = [
						_p[0],
						_p[1],
						_p[2],
						
						_p[3],
						_p[4],
						_p[5],
					]
					
				}
				
				ox = nx;
				oy = ny;
			}
			
			var newBr = _br.clone().setPoints(_points);
			
			array_push(_branch, newBr)
		}
		
		outputs[0].setValue(_branch);
	}
}