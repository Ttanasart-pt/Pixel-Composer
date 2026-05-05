function Node_MK_Blast_Attract(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Attract";
	color = COLORS.node_blend_mkblast;
	icon  = THEME.mkBlast;
	update_on_frame = true;
	setDrawIcon(s_node_mk_blast_attract);
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	
	////- =Blast
	newInput( 0, nodeValue_Struct( "Blast" )).setCustomData(global.MKBLAST_JUNC).setVisible(true, true);
	newInput(10, nodeValue_Toggle( "Mask", 0b01, [ "Flame", "Smoke" ] ))
	
	////- =Selection
	newInput( 5, nodeValue_Bool(   "Use Selection", false ))
	newInput( 6, nodeValue_Area(   "Area",   AREA_DEF_REF )).setUnitSimple();
	newInput( 7, nodeValue_Float(  "Falloff", 0 )).setCurvable( 8, CURVE_DEF_01);
	
	////- =Attract
	newInput( 3, nodeValue_Vec2(  "Target",    [.5,.5] )).setUnitSimple().setMappableRange(11, "Scatter", THEME.mk_blast_group);
	newInput( 2, nodeValue_Range( "Strength",  [0,1]   ));
	newInput( 9, nodeValue_Bool(  "Overshoot", false   ));
	
	////- =Spiral
	newInput( 4, nodeValue_Range( "Spiral",   [0,0]   ));
	// 12
	
	newOutput( 0, nodeValue_Output( "Blast", VALUE_TYPE.struct, [] )).setCustomData(global.MKBLAST_JUNC);
	
	input_display_list = [ s_MKFX, 1,  
		[ "Blast",     false    ],  0, 10, 
		[ "Selection", false, 5 ],  6,  7,  8, 
		[ "Attract",   false    ],  3, 11,  2,  9, 
		[ "Spiral",    false    ],  4,  
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Blast_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		InputDrawOverlay(inputs[ 3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		
		var _useSel = getInputData( 5);
		if(_useSel) {
			var _fall = getInputData( 7);
			InputDrawOverlay(inputs[6].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
			inputs[6].drawOverlayFallOff(_x, _y, _s, _fall);
		}
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Blast_Inline)) return;
		
		#region data
			var _dim  = getDimension();
			var _seed = inline_context.seed + getInputData(1);
			
			var _flameLayer = getInputData( 0);
			var _mask       = getInputData(10);
			
			var _useSel  = getInputData( 5);
			var _selArea = getInputData( 6);
			var _selFall = getInputData( 7);
			var _falCurv = getInputData( 8);
			
			var _target = getInputData( 3);
			var _targSc = getInputData(11);
			var _strns  = getInputData( 2);
			var _overs  = getInputData( 9);
			
			var _spiral = getInputData( 4);
			
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
				
				var _tx = _target[0] + random_range(_targSc[0], _targSc[1]);
				var _ty = _target[1] + random_range(_targSc[0], _targSc[1]);
				
				var _dist = point_distance( _flm.x, _flm.y, _tx, _ty);
				var _dirr = point_direction(_flm.x, _flm.y, _tx, _ty);
				var _life = max(0, _flm.life);
				
				var _len = _strn * _life;
				if(!_overs) _len = min(_len, _dist)
				
				var dx = lengthdir_x(_len, _dirr);
				var dy = lengthdir_y(_len, _dirr);
				
				_flm.x += dx;
				_flm.y += dy;
			}
		}
		
		outputs[0].setValue(_flameLayer);
	}
}
