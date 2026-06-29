function Node_MK_Blast_Gravity(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Gravity";
	color = COLORS.node_blend_mkblast;
	icon  = THEME.mkBlast;
	update_on_frame = true;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	
	////- =Blast
	newInput( 0, nodeValue_Struct( "Blast" )).setCustomData(global.MKBLAST_JUNC).setVisible(true, true);
	newInput( 8, nodeValue_Toggle( "Mask", 0b01, [ "Flame", "Smoke" ] ))
	
	////- =Selection
	newInput( 4, nodeValue_Bool(   "Use Selection", false ))
	newInput( 5, nodeValue_Area(   "Area",   AREA_DEF_REF )).setUnitSimple();
	newInput( 6, nodeValue_Float(  "Falloff", 0 )).setCurvable( 7, CURVE_DEF_01);
	
	////- =Gravity
	newInput( 2, nodeValue_Range(   "Strength",  [0,1]            ));
	newInput( 3, nodeValue_RotRand( "Direction", [0,-90,-90,0,0]  ));
	// 9
	
	newOutput( 0, nodeValue_Output( "Blast", VALUE_TYPE.struct, [] )).setCustomData(global.MKBLAST_JUNC);
	
	input_display_list = [ s_MKFX, 1,  
		[ "Blast",     false    ],  0,  8, 
		[ "Selection", false, 4 ],  5,  6,  7, 
		[ "Gravity",   false    ],  2,  3, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Blast_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _useSel = getInputData( 4);
		if(_useSel) {
			var _fall = getInputData( 6);
			drawOverlayInput(inputs[5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
			inputs[5].drawOverlayFallOff(_x, _y, _s, _fall);
		}
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Blast_Inline)) return;
		
		#region data
			var _dim  = getDimension();
			var _seed = inline_context.seed + getInputData(1);
			
			var _flameLayer = getInputData( 0);
			var _mask       = getInputData( 8);
			
			var _useSel  = getInputData( 4);
			var _selArea = getInputData( 5);
			var _selFall = getInputData( 6);
			var _falCurv = getInputData( 7);
			
			var _strns = getInputData( 2);
			var _dirrs = getInputData( 3);
			
			random_set_seed(_seed);
		#endregion
		
		for( var i = 0, n = array_length(_flameLayer); i < n; i++ ) {
			var _l = _flameLayer[i];
			
			for( var j = 0, m = array_length(_l.flames); j < m; j++ ) {
				var _flm = _l.flames[j];
				if(!is(_flm, MKBlast_Element)) continue;
				if(!(_flm.mask & _mask))    continue;
				
				var _strn = random_range(_strns[0], _strns[1]);
				if(_useSel) _strn *= area_get_point_influence(_selArea, _selFall, _falCurv, _flm.x, _flm.y);
				if(_strn == 0) continue;
				
				var _dirr = rotation_random_eval(_dirrs,, j);
				var _lif  = max(0, _flm.life);
				var _len  = _strn * _lif * _lif;
				
				var dx = lengthdir_x(_len, _dirr);
				var dy = lengthdir_y(_len, _dirr);
				
				_flm.x += dx;
				_flm.y += dy;
			}
		}
		
		outputs[0].setValue(_flameLayer);
	}
}
