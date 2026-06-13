function Node_Normal_Adjust(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Adjust Normal";
	
	////- =Normal
	newInput( 0, nodeValue_Surface( "Normal" ));
	newInput( 6, nodeValue_Surface( "Mask"   ));
	
	////- =Transform
	newInput( 1, nodeValue_Slider( "Intensity",  1, [0,4,.01] )).setMappable(2);
	newInput( 3, nodeValue_Rot(    "Rotate",     0            ));
	newInput( 4, nodeValue_Vec3(   "Scale",      [1,1,1]      ));
	newInput( 5, nodeValue_Bool(   "Normalize",  false        ));
	// input 6
	 
	newOutput( 0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Normal",    false ],  0,  6, 
		[ "Transform", false ],  1,  2,  3,  4,  5,   
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _norm = _data[ 0];
			var _mask = _data[ 6];
			
			var _ints = _data[ 1];
			var _rot  = _data[ 3];
			var _sca  = _data[ 4];
			var _nrm  = _data[ 5];
			
			if(!is_surface(_norm)) return _outData;
		#endregion
		
		surface_set_shader(_outData, sh_normal_adjust);
			shader_set_2( "dimension",  surface_get_dimension(_norm) );
			shader_set_s( "mask",       _mask                        );
			shader_set_i( "useMask",    is_surface(_mask)            );
			
			shader_set_m( "intensity",   _ints, _data[2], inputs[1] );
			shader_set_f( "rotation",    _rot  );
			shader_set_3( "scale",       _sca  );
			shader_set_i( "renormalize", _nrm  );
			
			draw_surface(_norm, 0, 0);
		surface_reset_shader();
		
		return _outData; 
	}
}