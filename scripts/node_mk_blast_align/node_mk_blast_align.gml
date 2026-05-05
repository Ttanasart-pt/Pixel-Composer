function Node_MK_Blast_Align(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Align";
	color = COLORS.node_blend_mkblast;
	icon  = THEME.mkBlast;
	update_on_frame = true;
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	
	////- =Blast
	newInput( 0, nodeValue_Struct( "Blast" )).setCustomData(global.MKBLAST_JUNC).setVisible(true, true);
	newInput( 2, nodeValue_Toggle( "Mask", 0b01, [ "Flame", "Smoke" ] ));
	
	////- =Align
	newInput( 3, nodeValue_Slider( "Speed", 1 ));
	// 4
	
	newOutput( 0, nodeValue_Output( "Blast", VALUE_TYPE.struct, [] )).setCustomData(global.MKBLAST_JUNC);
	
	input_display_list = [ s_MKFX, 1,  
		[ "Blast", false ],  0,  2,  
		[ "Align", false ],  3, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Blast_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static update = function() {
		if(!is(inline_context, Node_MK_Blast_Inline)) return;
		
		#region data
			var _dim  = getDimension();
			var _seed = inline_context.seed + getInputData(1);
			
			var _flameLayer = getInputData( 0);
			var _mask       = getInputData( 2);
			
			var _sped       = getInputData( 3);
			
			random_set_seed(_seed);
		#endregion
		
		for( var i = 0, n = array_length(_flameLayer); i < n; i++ ) {
			var _l = _flameLayer[i];
			
			for( var j = 0, m = array_length(_l.flames); j < m; j++ ) {
				var _flm = _l.flames[j];
				if(!is(_flm, MKBlast_Element)) continue;
				if(!(_flm.mask & _mask))       continue;
				if(_flm.px == _flm.x && _flm.py == _flm.y) continue;
				
				_flm.angleS = lerp_angle_direct(_flm.angleS, point_direction(_flm.px, _flm.py, _flm.x, _flm.y), _sped);
			}
		}
		
		outputs[0].setValue(_flameLayer);
	}
}
