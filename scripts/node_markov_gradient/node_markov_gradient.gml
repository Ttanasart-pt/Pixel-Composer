function Node_Markov_Gradient(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Markov Gradient";
	
	newActiveInput(2);
	newInput( 1, nodeValueSeed());
	newInput( 0, nodeValue_Surface( "Surface In" ));
	
	////- =Colors
	newInput( 3, nodeValue_Palette( "Colors" ));
	newInput( 4, nodeValue_Slider(  "Threshold",     .1 ));
	newInput( 5, nodeValue_Slider(  "Replace Chance", 1 )).setMappable(6);
	// inputs 7
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 2, 1, 0, 
		[ "Colors", false ], 3, 4, 5, 6, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static step = function() {}
	
	temp_surface = [noone];
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _seed = _data[ 1];
			var _surf = _data[ 0];
			
			var _col = _data[ 3];
			var _thr = _data[ 4];
			var _chn = _data[ 5];
			
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		var _sdim = surface_get_dimension(_surf);
		
		surface_set_shader(_outSurf, sh_markov_gradient);
			shader_set_2("dimension",      _sdim );
			shader_set_f("seed",           _seed + CURRENT_FRAME );
			
			shader_set_palette(_col);
			shader_set_f_map("matchChance", _chn, _data[6], inputs[5] );
			shader_set_f(    "threshold",   _thr );
			
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		return _outSurf; 
	}
}