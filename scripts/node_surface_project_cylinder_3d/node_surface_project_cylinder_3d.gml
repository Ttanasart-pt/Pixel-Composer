function Node_Surface_Project_Cylinder_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Surface Project Cylinder 3D";
	
	newInput( 0, nodeValue_Dimension());
	
	////- =Surfaces
	newInput( 1, nodeValue_Surface( "Cylinder" )).setDrawGroup(0);
	newInput( 2, nodeValue_Surface( "Top"      )).setDrawGroup(0);
	
		////- =/Unused (copied from surface project)
	newInput( 3, nodeValue_Surface( "Right"    )).setDrawGroup(0);
	newInput( 5, nodeValue_Surface( "Bottom"   )).setDrawGroup(1).setVisible(true, false);
	newInput( 6, nodeValue_Surface( "Back"     )).setDrawGroup(1).setVisible(true, false);
	newInput( 7, nodeValue_Surface( "Left"     )).setDrawGroup(1).setVisible(true, false);
	
	////- =Camera
	newInput( 4, nodeValue_Vec3(    "View Angle",  [30, 45, 0]   ));
	newInput(12, nodeValue_Vec3(    "Position",    [ 0,  0, 0]   ));
	newInput( 9, nodeValue_EButton( "Projection",   1 , [ "Perspective", "Orthographic" ] ));
	newInput(10, nodeValue_Slider(  "FOV",          60, [1,90,1] ));
	newInput(11, nodeValue_Float(   "Distance",     2            ));
	newInput( 8, nodeValue_Float(   "Scale",        3.46         ));
	
	////- =Geometry
	newInput(13, nodeValue_RotRange( "Angle Range", [0,360] ));
	
	////- =Rendering
	newInput(14, nodeValue_Range(    "Depth Range",   [0,1] ));
	// 15
	
	newOutput( 0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone ));
	newOutput( 1, nodeValue_Output("Depth Pass",  VALUE_TYPE.surface, noone ));
	newOutput( 2, nodeValue_Output("Normal Pass", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 0,
		[ "Surfaces",  false ],  1,  2, 
		[ "Camera",    false ],  4, 12,  9, 10, 11,  8,
		[ "Geometry",  false ], 13, 
		[ "Rendering", false ], 14, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static processData = function(_outData, _data, _array_index = 0) {
		#region data
			var _dim   = _data[ 0];
			
			var _sCyl  = _data[ 1];
			var _sTop  = _data[ 2];
			
			var _ang   = _data[ 4];
			var _pos   = _data[12];
			var _proj  = _data[ 9];
			var _fov   = _data[10];
			var _dist  = _data[11];
			var _sca   = _data[ 8];
			
			var _arng  = _data[13];
			
			var _depth = _data[14];
			
			inputs[10].setVisible(_proj == 0);
			inputs[11].setVisible(_proj == 0);
			inputs[ 8].setVisible(_proj == 1);
		#endregion
		
		surface_set_shader(_outData, sh_surface_project_cylinder_3d);
			shader_set_interpolation(_sCyl);
			
			shader_set_2( "dimension",  _dim   );
			shader_set_s( "sProfile",   _sCyl  );
			shader_set_s( "sTop",       _sTop  );
			shader_set_i( "sTop_use",   is_surface(_sTop)  );
			
			shader_set_3( "angle",      _ang   );
			shader_set_3( "position",   _pos   );
			
			shader_set_i( "projection", _proj  );
			shader_set_f( "fov",        _fov   );
			shader_set_f( "distant",    _dist  );
			shader_set_f( "scale",      _sca   );
			
			shader_set_2( "angRange",   _arng  );
			
			shader_set_2( "depthRange", _depth );
			
			draw_empty();
		surface_reset_shader();
		
		return _outData; 
	}
} 
