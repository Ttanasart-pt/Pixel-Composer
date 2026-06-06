function Node_Surface_Project_Cylinder_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Surface Project Cylinder 3D";
	
	newInput( 0, nodeValue_Dimension());
	
	////- =Surfaces
	newInput( 1, nodeValue_Surface( "Cylinder" )).setDrawGroup(0);
	newInput( 2, nodeValue_Surface( "Front"    )).setDrawGroup(0);
	newInput( 3, nodeValue_Surface( "Right"    )).setDrawGroup(0);
	
		////- =/Back side
	newInput( 5, nodeValue_Surface( "Bottom"   )).setDrawGroup(1).setVisible(true, false);
	newInput( 6, nodeValue_Surface( "Back"     )).setDrawGroup(1).setVisible(true, false);
	newInput( 7, nodeValue_Surface( "Left"     )).setDrawGroup(1).setVisible(true, false);
	
	////- =Camera
	newInput( 4, nodeValue_Vec3(    "View Angle",  [30, 45, 0]   ));
	newInput(12, nodeValue_Vec3(    "Position",    [ 0,  0, 0]   ));
	newInput( 9, nodeValue_EButton( "Projection",   1 , [ "Perspective", "Orthographic" ] ));
	newInput(10, nodeValue_Slider(  "FOV",          60, [1,90,1] ));
	newInput(11, nodeValue_Float(   "Distance",     1            ));
	newInput( 8, nodeValue_Float(   "Scale",        3.46         ));
	// 13
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0,
		[ "Surfaces",          false ],  1, // 2,  3, 
			// [ "/Back Texture", false ],  5,  6,  7, 
		[ "Camera",            false ],  4, 12,  9, 10, 11,  8,
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static processData = function(_outSurf, _data, _array_index = 0) {
		#region data
			var _dim   = _data[ 0];
			
			var _sTop  = _data[ 1];
			var _sFrn  = _data[ 2];
			var _sSid  = _data[ 3];
			
			var _sTopb = _data[ 5];
			var _sFrnb = _data[ 6];
			var _sSidb = _data[ 7];
			
			var _ang   = _data[ 4];
			var _pos   = _data[12];
			var _proj  = _data[ 9];
			var _fov   = _data[10];
			var _dist  = _data[11];
			var _sca   = _data[ 8];
			
			inputs[10].setVisible(_proj == 0);
			inputs[11].setVisible(_proj == 0);
			inputs[ 8].setVisible(_proj == 1);
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_surface_project_cylinder_3d);
			shader_set_interpolation(_sTop);
			
			shader_set_2( "dimension", _dim   );
			shader_set_s( "surTop",    _sFrn  );
			shader_set_s( "surFront",  _sSid  );
			shader_set_s( "surSide",   _sTop  );
			
			shader_set_s( "surTopB",   _sFrnb );
			shader_set_s( "surFrontB", _sSidb );
			shader_set_s( "surSideB",  _sTopb );
			
			shader_set_i( "surTopB_use",   is_surface(_sFrnb) );
			shader_set_i( "surFrontB_use", is_surface(_sSidb) );
			shader_set_i( "surSideB_use",  is_surface(_sTopb) );
			
			shader_set_3( "angle",      _ang   );
			shader_set_3( "position",   _pos   );
			
			shader_set_i( "projection", _proj  );
			shader_set_f( "fov",        _fov   );
			shader_set_f( "distant",    _dist  );
			shader_set_f( "scale",      _sca   );
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf; 
	}
} 
