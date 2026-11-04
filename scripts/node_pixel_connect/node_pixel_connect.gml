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
	newInput(12, nodeValue_Bool(    "Self Connect", true ));
	newInput( 7, nodeValue_Slider(  "Max Distance",   .5 ));
	newInput(11, nodeValue_Int(     "Resolution",     32 ));
	
	////- =Rendering
	newInput( 8, nodeValue_EScroll( "Blend Type", 0, [ "Closer", "Mix" ] ));
	newInput( 9, nodeValue_EScroll( "Blend Mode", 1, [ "Override", "Multiply" ] ));
	newInput(10, nodeValue_Color(   "Color",      ca_white ));
	// 13
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  5,  6, 
		[ "Surface",     true ],  0,  1,  2,  3,  4, 
		[ "Connection", false ], 12,  7, 11, 
		[ "Rendering",  false ],  8,  9, 10, 
		[ "Surfaces",   false ], 
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		newInput(index, nodeValue_Surface("Surface")).setVisible(true, true);
		
		postCreateNewInput(index);
		refreshDynamicDisplay();
		array_push(input_display_list, index);
		
		return inputs[index];
	} 
	
	setDynamicInput(1);
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_oversample();
	
	temp_surface = [noone,noone];
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf    = _data[ 0];
			
			var _selfCon = _data[12];
			var _maxDist = _data[ 7];
			var _angRes  = _data[11];
			
			var _blndTyp = _data[ 8];
			var _blndMod = _data[ 9];
			var _blndCol = _data[10];
		
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		var _dim = surface_get_dimension(_surf);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		surface_set_shader(temp_surface[1], sh_pixel_connect);
			shader_set_i( "sampleMode", getAttribute("oversample"));
			shader_set_2( "dimension",    _dim    );
			shader_set_i( "useSurface",   0       );
			
			shader_set_i( "selfCon",     _selfCon );
			shader_set_f( "maxDistance", _maxDist );
			shader_set_f( "angRes",      _angRes  );
			
			shader_set_i( "blendType",   _blndTyp );
			shader_set_i( "blendMode",   _blndMod );
			shader_set_c( "blendColor",  _blndCol );
			
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		var _amo = getInputAmount();
		var _bg  = 1;
		
		for( var i = 0; i < _amo; i++ ) {
			var ind = input_fix_len + i * data_length;
			_bg = !_bg;
			
			surface_set_shader(temp_surface[_bg], sh_pixel_connect);
				shader_set_i( "useSurface",   1         );
				shader_set_s( "connectSurf", _data[ind] );
				
				draw_surface(temp_surface[!_bg], 0, 0);
			surface_reset_shader();
			
		}
		
		surface_set_shader(_outSurf, sh_sample, true, BLEND.over);
			draw_surface(temp_surface[_bg], 0, 0);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply_input(_surf, _outSurf, _data[1], _data[2], inputs[1]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}