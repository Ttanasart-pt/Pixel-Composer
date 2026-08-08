function Node_MK_Tree_Wiggle(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Wiggle Branch";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	update_on_frame = true;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct( "Tree", noone )).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	////- =Selection
	newInput( 5, nodeValue_EScroll( "Select Type", 0, [ "All", "Area", "Band" ] ));
	newInput( 6, nodeValue_Area(    "Area",      DEF_AREA_REF )).setUnitSimple();
	newInput( 9, nodeValue_Vec2(    "Center",    [.5,.5]      )).setUnitSimple();
	newInput(10, nodeValue_Float(   "Width",       8          ));
	newInput(11, nodeValue_Rotation("Angle",       0          ));
	newInput( 7, nodeValue_Float(   "Falloff Distance", 0     )).setCurvable( 8, CURVE_DEF_01);
	
	////- =Wiggle
	newInput( 4, nodeValue_Range(   "Speed",     [1,1], true   ));
	newInput( 2, nodeValue_Range(   "Strength",  [4,4], true   ));
	newInput( 3, nodeValue_RotRand( "Direction", [0,0,360,0,0] ));
	// 12
	
	newOutput(0, nodeValue_Output("Tree", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_JUNC);
	
	input_display_list = [ s_MKFX,  1,  0, 
		[ "Selection", false ],  5,  6,  9, 10, 11, [7, false],  8,  
		[ "Wiggle",    false ],  4,  2,  3, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _resT = outputs[0].getValue();
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
			var _seed  = inline_context.seed + getInputData(1);
			
			var _tree  = getInputData( 0);
			
			var _aType = getInputData( 5);
			var _area  = getInputData( 6);
			var _cent  = getInputData( 9);
			var _widt  = getInputData(10);
			var _bang  = getInputData(11);
			var _falW  = getInputData( 7);
			var _falC  = getInputData( 8), fal_curve = new curveMap(_falC);
			
			var _sped  = getInputData( 4);
			var _strn  = getInputData( 2);
			var _angr  = getInputData( 3);
			
			inputs[ 6].setVisible(_aType == 1);
			inputs[ 9].setVisible(_aType == 2);
			inputs[10].setVisible(_aType == 2);
			inputs[11].setVisible(_aType == 2);
			
			inputs[ 7].setVisible(_aType >  0);
			
			random_set_seed(_seed);
		#endregion
		
		_tree = variable_clone(_tree);
		var _treeArr = array_spread(_tree);
		
		for( var i = 0, n = array_length(_treeArr); i < n; i++ ) {
			var _tr   = _treeArr[i];
			var _segs = _tr.segments;
			var _totl = _tr.totalLength;
			var _wstr = random_range(_strn[0], _strn[1]);
			var _ang  = rotation_random_eval(_angr,, i);
			
			if(array_empty(_segs)) continue;
			
			var sx  = _segs[0].x;
			var sy  = _segs[0].y;
			var wei = 1;
			
			switch(_aType) {
				case 1 : wei = area_get_point_influence(_area, _falW, fal_curve, sx, sy);                                    break;
				case 2 : wei = distance_to_line_angle_influence(sx, sy, _cent[0], _cent[1], _bang, _widt, _falW, fal_curve); break;
			}
			
			var _fspd = round(random_range(_sped[0], _sped[1]));
			
			var _inf  = (_wstr *  1) * sin(frac(random(1) + CURRENT_FRAME / TOTAL_FRAMES) * pi * 2 * (_fspd))     + 
			            (_wstr * .6) * sin(frac(random(1) + CURRENT_FRAME / TOTAL_FRAMES) * pi * 2 * (_fspd - 1)) + 
			            (_wstr * .3) * sin(frac(random(1) + CURRENT_FRAME / TOTAL_FRAMES) * pi * 2 * (_fspd - 2));
			            
			var _wx   = lengthdir_x(_inf * wei, _ang);
			var _wy   = lengthdir_y(_inf * wei, _ang);
			
			for( var j = 0, m = array_length(_segs); j < m; j++ ) {
				var _sg = _segs[j];
				var _ll = _tr.segmentLengths[j];
				
				_sg.x += _wx * _ll / _totl;
				_sg.y += _wy * _ll / _totl;
			}
			
			_tr.getLength();
		}
		
		outputs[0].setValue(_tree);
	}
	
}