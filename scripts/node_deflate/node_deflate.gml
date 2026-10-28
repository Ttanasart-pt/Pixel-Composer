function Node_Deflate(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Deflate";
	
	newActiveInput(5);
	newInput( 6, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" )).setRequired();
	newInput( 1, nodeValue_Surface( "Mask"       ));
	newInput( 2, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(1, 3); // inputs 3, 4
	
	////- =Deflate
	newInput( 7, nodeValue_Float( "Radius",    .25 )).setUnitSimple();
	newInput( 9, nodeValue_Float( "Intensity", .5  )).setMappable(12);
	newInput( 8, nodeValue_Float( "Factor",     5  ));
	newInput(10, nodeValue_Float( "_Factor",    1  ));
	newInput(11, nodeValue_Float( "Resolution", 4  ));
	// 13
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  5,  6, 
		[ "Surfaces",  true ],  0,  1,  2,  3,  4, 
		[ "Deflate",  false ],  7,  9, 12,  8, 11, 
	];
	
	////- Nodes
	
	temp_surface = array_create( 2, noone );
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			
			var _rad  = _data[ 7];
			var _int  = _data[ 8];
			var _off  = _data[ 9];
			var _fac  = _data[10];
			var _res  = _data[11];
		
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		var _dim = surface_get_dimension(_surf);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1], surface_rgba16float);
		
		surface_set_shader(temp_surface[0], sh_deflate_mask);
			shader_set_2( "dimension", _dim );
			shader_set_f( "radius",    _rad );
			
			draw_surface(_surf, 0, 0);
		surface_reset_shader();
		
		surface_set_shader(temp_surface[1], sh_deflate_normal);
			shader_set_2( "dimension", _dim );
			shader_set_f( "radius",    _rad );
			shader_set_f( "amount",    _int );
			shader_set_f( "factor",    _fac );
			shader_set_m( "offset",    _off, _data[12], inputs[ 9] );
			shader_set_f( "resolution",_res );
			
			gpu_set_tex_filter(true);
			draw_surface(temp_surface[0], 0, 0);
			gpu_set_tex_filter(false);
		surface_reset_shader();
		
		surface_set_shader(_outSurf, sh_deflate);
			shader_set_2( "dimension", _dim );
			shader_set_f( "radius",    _rad );
			shader_set_f( "amount",    _int );
			shader_set_f( "factor",    _fac );
			shader_set_m( "offset",    _off, _data[12], inputs[ 9] );
			
			shader_set_s( "original",  _surf );
			shader_set_s( "sdf",       temp_surface[0] );
			
			draw_surface(temp_surface[1], 0, 0);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply_input(_surf, _outSurf, _data[1], _data[2], inputs[1]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}