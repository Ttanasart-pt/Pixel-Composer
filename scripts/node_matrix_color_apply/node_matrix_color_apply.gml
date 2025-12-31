function Node_Matrix_Color_Apply(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Matrix Color Apply";
	
	newActiveInput(5);
	newInput( 6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 3, nodeValue_Surface( "Mask"       ));
	newInput( 4, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(3, 7); // inputs 7, 8 
	
	////- =Effect
	newInput( 1, nodeValue_Matrix( "Matrix"       )).setVisible(true, true);
	newInput( 2, nodeValue_Slider( "Intensity", 1 ));
	// inputs 9
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
		
	input_display_list = [ 5, 6, 
		[ "Surfaces",  true ], 0, 3, 4, 7, 8, 
		[ "Effect",   false ], 1, 2, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _matx = _data[1];
		var _ints = _data[2];
		
		var _dat  = array_verify(_matx.raw, 9);
		
		surface_set_shader(_outSurf, sh_matrix_color_apply);
		    shader_set_dim( "dimension", _surf )
			shader_set_f(   "matrix",    _dat  );
			shader_set_f(   "intensity", _ints );
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}