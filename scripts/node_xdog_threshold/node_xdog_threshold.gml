function Node_XDoG_Threshold(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "XDoG Threshold";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 1, nodeValue_Surface( "Mask"       ));
	newInput( 2, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(1, 3); // inputs 3, 4
	
	////- =XDoG
	newInput( 7, nodeValue_Float(  "Radius", .25 )).setUnitSimple();
	newInput( 8, nodeValue_Float(  "k",        8 ));
	newInput( 9, nodeValue_Float(  "Gamma",    1 )).setMappable(12);
	newInput(10, nodeValue_Slider( "Epsilon", .1 )).setMappable(13);
	
	////- =Rendering
	newInput(15, nodeValue_Bool(   "Edge",    false ));
	newInput(11, nodeValue_Slider( "Smoothness", .1 )).setMappable(14);
	// inputs 16
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output("DoG",         VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 5, 6, 
		[ "Surface",   false ],  0,  1,  2,  3,  4, 
		[ "XDoG",      false ],  7,  8,  9, 12, 10, 13, 
		[ "Rendering", false ], 15, 11, 14, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	surface_blur_init();
	
	temp_surface = [ noone, noone, noone ];
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			
			var _size = _data[ 7];
			var  k    = _data[ 8];
			var _gamm = _data[ 9];
			var _epsi = _data[10];
			
			var _edge = _data[15];
			var _smth = _data[11];
			
			if(!is_surface(_surf)) return _outData; 
		#endregion
		
		var _dim = surface_get_dimension(_surf);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		var args = new blur_gauss_args(_surf, _size).setBG(true, c_black);
		var g1   = surface_apply_gaussian(args);
		surface_set_shader(temp_surface[0]); 
			draw_surface(g1, 0, 0);
		surface_reset_shader();
		
		var args = new blur_gauss_args(_surf, _size * k).setBG(true, c_black);
		var g2   = surface_apply_gaussian(args);
		surface_set_shader(temp_surface[1]); 
			draw_surface(g2, 0, 0);
		surface_reset_shader();
		
		var _outSurf = _outData[0];
		var _outDoG  = _outData[1];
		
		surface_set_shader(_outDoG, sh_xdog_different);
			shader_set_s( "g1", temp_surface[0] );
			shader_set_s( "g2", temp_surface[1] );
			
			shader_set_i(     "edge",  _edge );
			shader_set_f_map( "gamma", _gamm, _data[12], inputs[9] );
			
			draw_empty();
		surface_reset_shader();
		
		surface_set_shader(_outSurf, sh_xdog_threshold);
			shader_set_f_map( "epsilon",    _epsi, _data[13], inputs[10] );
			shader_set_f_map( "smoothness", _smth, _data[14], inputs[11] );
			
			draw_surface(_outDoG, 0, 0);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outData; 
	}
}