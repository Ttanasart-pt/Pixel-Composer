function Node_MK_Tree_Spiral_Branch(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Spiral Branch";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct( "Branch", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Selection
	newInput( 5, nodeValue_EScroll( "Select Type", 0, [ "All", "Area", "Band" ] ));
	newInput( 6, nodeValue_Area(    "Area",      DEF_AREA_REF )).setUnitSimple();
	newInput( 9, nodeValue_Vec2(    "Center",    [.5,.5]      )).setUnitSimple();
	newInput(10, nodeValue_Float(   "Width",       8          ));
	newInput(11, nodeValue_Rotation("Angle",       0          ));
	newInput( 7, nodeValue_Float(   "Falloff Distance", 0     )).setCurvable( 8, CURVE_DEF_01);
	
	////- =Spiral
	newInput( 2, nodeValue_Range(    "Amplitude", [4,4], true )).setCurvable(3);
	newInput( 4, nodeValue_EButton(  "Flip",       0, [ "None", "Random", "Starting Angle" ] ));
	// 12
	
	newOutput( 0, nodeValue_Output("Branches", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ s_MKFX, 1, 0, 
		[ "Selection", false ],  5,  6,  9, 10, 11, [7, false],  8,  
		[ "Spiral",    false ],  2,  3,  4, 
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
		
		var _aType = getInputData( 5);
		var _falW  = getInputData( 7);
		
		switch(_aType) {
			case 1 : // area
				drawOverlayInput(inputs[ 6].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
				break;
				
			case 2 : // band
				var _cent  = getInputData( 9);
				var _widt  = getInputData(10);
				var _bang  = getInputData(11);
				
				var cx = _x + _cent[0] * _s;
				var cy = _y + _cent[1] * _s;
				
				var cdx = lengthdir_x(9999, _bang);
				var cdy = lengthdir_y(9999, _bang);
				
				var dx = lengthdir_x(_widt * _s, _bang + 90);
				var dy = lengthdir_y(_widt * _s, _bang + 90);
				
				draw_set_color(COLORS._main_accent);
				draw_line(cx+dx - cdx, cy+dy - cdy, cx+dx + cdx, cy+dy + cdy);
				draw_line(cx-dx - cdx, cy-dy - cdy, cx-dx + cdx, cy-dy + cdy);
				
				drawOverlayInput(inputs[ 9].drawOverlay(hover, active, _x, _y, _s, _mx, _my, 1));
				drawOverlayInput(inputs[10].drawOverlay(hover, active, cx, cy, _s, _mx, _my, _bang + 90));
				drawOverlayInput(inputs[11].drawOverlay(hover, active, cx, cy, _s, _mx, _my));
				break;
		}
		
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		#region data
			var _seed = inline_context.seed + getInputData(1);
			var _gDir = inline_context.gravityDir;
			
			var _bran = getInputData( 0);
			
			var _aType = getInputData( 5);
			var _area  = getInputData( 6);
			var _cent  = getInputData( 9);
			var _widt  = getInputData(10);
			var _bang  = getInputData(11);
			var _falW  = getInputData( 7);
			var _falC  = getInputData( 8), fal_curve = new curveMap(_falC);
			
			var _ampl = getInputData( 2);
			var _ampC = getInputData( 3), amp_curve = inputs[2].attributes.curved? new curveMap(_ampC) : undefined;
			var _flip = getInputData( 4);
			
			inputs[ 6].setVisible(_aType == 1);
			inputs[ 9].setVisible(_aType == 2);
			inputs[10].setVisible(_aType == 2);
			inputs[11].setVisible(_aType == 2);
			
			inputs[ 7].setVisible(_aType >  0);
			
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
			
			var sx  = _bpnt[0][0];
			var sy  = _bpnt[0][1];
			var wei = 1;
			
			switch(_aType) {
				case 1 : wei = area_get_point_influence(_area, _falW, fal_curve, sx, sy);                                    break;
				case 2 : wei = distance_to_line_angle_influence(sx, sy, _cent[0], _cent[1], _bang, _widt, _falW, fal_curve); break;
			}
			
			var ampl = random_range(_ampl[0], _ampl[1]) * wei;
			if(_flip == 1) ampl *= choose(-1, 1);
			
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