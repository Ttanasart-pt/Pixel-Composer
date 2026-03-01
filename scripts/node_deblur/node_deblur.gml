function Node_Deblur(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Deblur";
	
	newActiveInput(1);
	newInput(4, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 2, nodeValue_Surface( "Mask"       ));
	newInput( 3, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(2, 5); // inputs 5, 6, 
	
	////- =Effect
	newInput(10, nodeValue_EScroll( "Method", 0, [ "Unsharp Mask", "Edge Enhancement", "Wiener Filter" ] ));
	newInput( 7, nodeValue_Float( "Radius",   8 ));
	newInput( 8, nodeValue_Float( "Strength", 1 ));
	newInput( 9, nodeValue_Float( "Denoise",  1 ));
	// 11
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 4, 
		[ "Surfaces", true ],  0,  2,  3,  5,  6, 
		[ "Effect",  false ], 10,  7,  8,  9, 
	]
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { }
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			
			var _type = _data[10];
			var _radi = _data[ 7];
			var _strn = _data[ 8];
			var _supp = _data[ 9];
		#endregion
		
		var _dim = surface_get_dimension(_data[0]);
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_shader(_outSurf, sh_deblur, true, BLEND.over);
			shader_set_i("sampleMode",    getAttribute("oversample"));
			shader_set_2("dimension",     _dim  );
			
			shader_set_i("method",        _type );
			shader_set_f("radius",        _radi );
			shader_set_f("strength",      _strn );
			shader_set_f("noiseSuppress", _supp );
			shader_set_f("gaussianWeights", [0.06136, 0.24477, 0.38774, 0.24477, 0.06136] );
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[2], _data[3]);
		_outSurf = channel_apply(_surf, _outSurf, _data[4]);
		
		return _outSurf; 
	}
}