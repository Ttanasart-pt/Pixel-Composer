function Node_Convolution(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Convolution";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, array_create(4, THEME.inspector_channel) ));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" )).setRequired();
	newInput(3, nodeValue_Surface( "Mask"       ));
	newInput(4, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(3, 7); // inputs 7, 8, 
	
	////- =Kernel
	newInput(10, nodeValue_Int(    "Size",      3     )).setValidator(VV_clamp(3, 16));
	newInput( 1, nodeValue_Matrix( "Kernel",          ));
	newInput( 9, nodeValue_Bool(   "Normalize", false ));
	newInput(11, nodeValue_Rot(    "Rotation",  0     ));
	// 12
	
	/* UNUSED */ newInput( 2, nodeValue_EScroll("Oversample mode", 0, [ "Empty", "Clamp", "Repeat" ]));
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  5,  6, 
		[ "Surfaces",  true ],  0,  3,  4,  7,  8, 
		[ "Kernel",   false ], 10,  1,  9, 11, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_interpolation();
	attribute_oversample();
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[ 0];
			
			var _ker  = _data[ 1];
			var _nrm  = _data[ 9];
			var _rot  = _data[11];
			
			var _siz  = max(3, _data[10]);
			_ker.setSize(_siz);
			
		#endregion
		
		var _dat = _ker.raw;
		var _dim = surface_get_dimension(_outSurf);
		
		surface_set_shader(_outSurf, sh_convolution, true, BLEND.over);
			shader_set_interpolation(_surf);
			shader_set_i( "sampleMode",  getAttribute("oversample"));
			shader_set_2( "dimension",   _dim );
			
			shader_set_i( "size",        _siz );
			shader_set_f( "kernel",      _dat );
			
			shader_set_i( "normalized",  _nrm );
			shader_set_f( "rotation",    _rot );
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply_input(_surf, _outSurf, _data[3], _data[4], inputs[3]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
}