function Node_Refract(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Refract";
	
	newActiveInput(1);
	newInput(2, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In"  ));
	newInput(3, nodeValue_Surface( "Mask"        ));
	newInput(4, nodeValue_Slider(  "Mix", 1      ));
	__init_mask_modifier(3, 5); // inputs 5, 6 
	
	////- =Refract
	newInput( 7, nodeValue_Surface( "Normal Map" ));
	newInput( 8, nodeValue_Surface( "Depth Map"  ));
	newInput( 9, nodeValue_Float(   "Height",      4   )).setMappable(12);
	newInput(10, nodeValue_Float(   "Distance",    4   )).setMappable(13);
	newInput(11, nodeValue_Float(   "IOR",         1.3 )).setMappable(14);
	newInput(15, nodeValue_Float(   "Perspective", 0   ))
	// input 16
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 2, 
		[ "Surface",   true ], 0, 3, 4, 5, 6, 
		[ "Refract",  false ], 7, 8, 9, 12, 10, 13, 11, 14, 15, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	attributes.oversample = 3;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		
		var _surf  = _data[ 0];
		
		var _normS = _data[ 7];
		var _deptS = _data[ 8];
		var _dept  = _data[ 9];
		var _dist  = _data[10];
		var _ior   = _data[11];
		var _pres  = _data[15];
		
		var _dim   = surface_get_dimension(_surf);
		
		surface_set_shader(_outSurf, sh_refract);
			shader_set_interpolation(_surf);
			
			shader_set_surface( "refNormalSurf", _normS );
			shader_set_surface( "refDepthSurf",  _deptS );
			
			shader_set_2( "dimension",    _dim  );
			shader_set_f( "perspective",  _pres );
			shader_set_f_map( "depth",    _dept, _data[12], inputs[ 9] );
			shader_set_f_map( "offset",   _dist, _data[13], inputs[10] );
			shader_set_f_map( "IOR",      _ior,  _data[14], inputs[11] );
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_surf, _outSurf, _data[2]);
		return _outSurf; 
	}
}