function Node_MK_Blast_Wave(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Wave";
	color = COLORS.node_blend_mkblast;
	icon  = THEME.mkBlast;
	update_on_frame = true;
	setDrawIcon(s_node_mk_blast_wave);
	setDimension(96, 48);
	
	newInput( 1, nodeValueSeed());
	
	////- =Blast
	newInput( 0, nodeValue_Struct( "Blast" )).setCustomData(global.MKBLAST_JUNC).setVisible(true, true);
	
	////- =Wave
	newInput( 2, nodeValue_Range( "Strength",  [0,1]  ));
	newInput( 3, nodeValue_Range( "Frequency", [4,4]  ));
	newInput( 4, nodeValue_Range( "Phase",     [0,0]  ));
	// 3
	
	newOutput( 0, nodeValue_Output( "Blast", VALUE_TYPE.struct, [] )).setCustomData(global.MKBLAST_JUNC);
	
	input_display_list = [ s_MKFX, 1,  
		[ "Blast", false ],  0,  
		[ "Wave",  false ],  2,  3,  4, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Blast_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Blast_Inline)) return;
		
		#region data
			var _dim  = getDimension();
			var _seed = inline_context.seed + getInputData(1);
			
			var _flameLayer = getInputData( 0);
			
			var _strns = getInputData( 2);
			var _freqs = getInputData( 3);
			var _phass = getInputData( 4);
			
			random_set_seed(_seed);
		#endregion
		
		
		for( var i = 0, n = array_length(_flameLayer); i < n; i++ ) {
			var _l = _flameLayer[i];
			
			for( var j = 0, m = array_length(_l.flames); j < m; j++ ) {
				var _flm = _l.flames[j];
				if(!is(_flm, MKBlast_Ball)) continue;
				if(!_flm.hot) continue;
				
				var _strn = random_range(_strns[0], _strns[1]);
				var _freq = random_range(_freqs[0], _freqs[1]);
				var _phas = random_range(_phass[0], _phass[1]);
				
				var _dirr = _flm.direction + 90;
				var _life = (_flm.lifeRatio + _phas) * _freq * pi;
				
				var _len  = sin(_life) * _strn;
				
				var dx = lengthdir_x(_len, _dirr);
				var dy = lengthdir_y(_len, _dirr);
				
				_flm.x += dx;
				_flm.y += dy;
			}
		}
		
		outputs[0].setValue(_flameLayer);
	}
}
