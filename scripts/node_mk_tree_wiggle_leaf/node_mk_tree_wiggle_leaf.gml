function Node_MK_Tree_Wiggle_Leaf(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Wiggle Leaves";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	update_on_frame = true;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Struct( "Leaves", noone)).setVisible(true, true).setCustomData(global.MKTREE_LEAVES_JUNC);
	
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
	
	newOutput(0, nodeValue_Output("Tree", VALUE_TYPE.struct, noone)).setCustomData(global.MKTREE_LEAVES_JUNC);
	
	input_display_list = [ s_MKFX, 1, 0, 
		[ "Selection", false ],  5,  6,  9, 10, 11, [7, false],  8,  
		[ "Wiggle",    false ],  4,  2,  3, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
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
			
			var _leaf  = getInputData(0);
			
			var _aType = getInputData( 5);
			var _area  = getInputData( 6);
			var _cent  = getInputData( 9);
			var _widt  = getInputData(10);
			var _bang  = getInputData(11);
			var _falW  = getInputData( 7);
			var _falC  = getInputData( 8), fal_curve = new curveMap(_falC);
			
			var _sped  = getInputData(4);
			var _strn  = getInputData(2);
			var _angr  = getInputData(3);
			
			inputs[ 6].setVisible(_aType == 1);
			inputs[ 9].setVisible(_aType == 2);
			inputs[10].setVisible(_aType == 2);
			inputs[11].setVisible(_aType == 2);
			
			inputs[ 7].setVisible(_aType >  0);
			
			random_set_seed(_seed);
		#endregion
		
		var _outLeaf = outputs[0].getValue();
		
		for( var i = 0, n = array_length(_leaf); i < n; i++ ) {
			var _lf     = _leaf[i];
			_outLeaf[i] = _lf;
			
			if(!is(_lf, __MK_Tree_Leaf)) continue;
			
			var sx  = _lf.x;
			var sy  = _lf.y;
			var wei = 1;
			
			switch(_aType) {
				case 1 : wei = area_get_point_influence(_area, _falW, fal_curve, sx, sy);                                    break;
				case 2 : wei = distance_to_line_angle_influence(sx, sy, _cent[0], _cent[1], _bang, _widt, _falW, fal_curve); break;
			}
			
			var _wstr = random_range(_strn[0], _strn[1]);
			var _ang  = rotation_random_eval(_angr,, i);
			
			var _fspd = round(random_range(_sped[0], _sped[1]));
			
			var _inf  = (_wstr *  1) * sin(frac(random(1) + CURRENT_FRAME / TOTAL_FRAMES) * pi * 2 * (_fspd))     + 
			            (_wstr * .6) * sin(frac(random(1) + CURRENT_FRAME / TOTAL_FRAMES) * pi * 2 * (_fspd - 1)) + 
			            (_wstr * .3) * sin(frac(random(1) + CURRENT_FRAME / TOTAL_FRAMES) * pi * 2 * (_fspd - 2));
			
			_lf.dir += _inf * wei;
			_lf.recalDir();
		}
		
		outputs[0].setValue(_outLeaf);
	}
	
}