function Node_Pixel_Connect(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Connect";
	
	newActiveInput(5);
	newInput( 6, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" )).setRequired();
	newInput( 1, nodeValue_Surface( "Mask"       ));
	newInput( 2, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(1, 3); // inputs 3, 4
	
	////- =Connection
	newInput( 7, nodeValue_Slider(  "Max Distance", .5 ));
	newInput(11, nodeValue_Int(     "Resolution",   32 ));
	
	////- =Rendering
	newInput( 8, nodeValue_EScroll( "Blend Type", 0, [ "Closer", "Mix" ] ));
	newInput( 9, nodeValue_EScroll( "Blend Mode", 1, [ "Override", "Multiply" ] ));
	newInput(10, nodeValue_Color(   "Color",      ca_white ));
	// 12
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  5,  6, 
		[ "Surfaces",    true ],  0,  1,  2,  3,  4, 
		[ "Connection", false ],  7, 11, 
		[ "Rendering",  false ],  8,  9, 10, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_oversample();
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf    = _data[ 0];
			
			var _maxDist = _data[ 7];
			var _angRes  = _data[11];
			
			var _blndTyp = _data[ 8];
			var _blndMod = _data[ 9];
			var _blndCol = _data[10];
		
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		var _dim = surface_get_dimension(_surf);
		
		surface_set_shader(_outSurf, sh_pixel_connect);
			shader_set_i( "sampleMode", getAttribute("oversample"));
			
			shader_set_2( "dimension",    _dim    );
			shader_set_f( "maxDistance", _maxDist );
			shader_set_f( "angRes",      _angRes  );
			
			shader_set_i( "blendType",   _blndTyp );
			shader_set_i( "blendMode",   _blndMod );
			shader_set_c( "blendColor",  _blndCol );
			
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply_input(_surf, _outSurf, _data[1], _data[2], inputs[1]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}