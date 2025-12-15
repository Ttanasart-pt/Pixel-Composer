function Node_Scatter_Sampler(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Scatter Sampler";
	dimension_index = 1;
	
	////- =Surfaces
	newInput( 1, nodeValue_Dimension());
	newInput(11, nodeValue_Surface( "Mask" ));
	
	////- =Texture
	newInput( 2, nodeValue_EScroll( "Texture Type", 0, [ "Surface", "Circle" ] ));
	newInput( 3, nodeValue_Surface( "Surface" ));
	newInput( 9, nodeValue_Slider(  "Radius",    1, [0,2,.01] )).setMappable(13);
	newInput(12, nodeValue_Curve(   "Intensity", CURVE_DEF_01 ));
	
	////- =Transform
	newInput( 4, nodeValue_Float( "Scale", 4 )).setMappable(14);
	
	////- =Iteration
	newInput( 6, nodeValue_Int(     "Iteration",       4 ));
	newInput( 7, nodeValue_Float(   "Itr. Scale",      2 )).setMappable(15);
	newInput( 8, nodeValue_Float(   "Itr. Amplitude", .5 )).setMappable(16);
	newInput(10, nodeValue_EScroll( "Blend Mode", 0, [ "Add", "Max" ] ));
	
	////- =Random
	newInput( 0, nodeValueSeed());
	newInput( 5, nodeValue_Slider( "Randomize", 1 ));
	// inputs 13
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Output",    false ],  1, 11, 
		[ "Inputs",    false ],  2,  3,  9, 13, 
		[ "Transform", false ],  4, 14, 
		[ "Iteration", false ],  6,  7, 15,  8, 16, 10, 
		[ "Random",    false ],  0,  5, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _dim  = _data[ 1];
			var _mask = _data[11];
			
			var _type = _data[ 2];
			var _surf = _data[ 3];
			var _radd = _data[ 9];
			var _curv = _data[12];
			
			var _scal = _data[ 4];
			
			var _iitr = _data[ 6];
			var _itrs = _data[ 7];
			var _itra = _data[ 8];
			var _blnd = _data[10];
			
			var _seed = _data[ 0];
			var _rand = _data[ 5];
			
			inputs[ 3].setVisible(_type == 0, _type == 0);
			inputs[12].setVisible(_type != 0);
		#endregion
		
		surface_set_shader(_outSurf, sh_scatter_sampler);
			shader_set_s( "mask",      _mask );
			shader_set_i( "useMask",   is_surface(_mask) );
			
			shader_set_f( "seed",      _seed );
			shader_set_f( "randomize", _rand );
			
			shader_set_i(     "type",      _type );
			shader_set_s(     "surface",   _surf );
			shader_set_f_map( "radius",    _radd, _data[13], inputs[9] );
			shader_set_curve( "inten",     _curv );
			
			shader_set_f_map( "scale",     _scal, _data[14], inputs[4] );
			
			shader_set_i(     "iteration", _iitr );
			shader_set_f_map( "itrScale",  _itrs, _data[15], inputs[7] );
			shader_set_f_map( "itrAmpli",  _itra, _data[16], inputs[8] );
			shader_set_i(     "itrBlend",  _blnd );
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf; 
	}
}