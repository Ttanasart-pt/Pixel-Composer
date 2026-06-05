function Node_Heightmap_Project_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Heightmap Project 3D";
	
	newInput( 0, nodeValue_Dimension());
	
	////- =Surfaces
	newInput( 1, nodeValue_Surface( "Heightmap"     ));
	newInput( 2, nodeValue_Surface( "Texture"       ));
	newInput(10, nodeValue_Surface( "Texture Side"  ));
	newInput(11, nodeValue_Surface( "Texture Front" ));
	
	////- =Camera
	newInput( 3, nodeValue_Vec3(    "View Angle",  [30, 45, 0]   ));
	newInput( 8, nodeValue_Vec3(    "Position",    [ 0,  0, 0]   ));
	newInput( 4, nodeValue_EButton( "Projection",   1 , [ "Perspective", "Orthographic" ] ));
	newInput( 5, nodeValue_Slider(  "FOV",          60, [1,90,1] ));
	newInput( 6, nodeValue_Float(   "Distance",     1            ));
	newInput( 7, nodeValue_Float(   "Scale",        3.46         ));
	
	////- =Rendering
	newInput( 9, nodeValue_Gradient( "Height Color", gra_white   ));
	// 12
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0,
		[ "Surfaces",  false ],  1,  2, 10, 11, 
		[ "Camera",    false ],  3,  8,  4,  5,  6,  7, 
		[ "Rendering", false ],  9, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index = 0) {
		#region data
			var _dim   = _data[ 0];
			
			var _higm  = _data[ 1];
			var _text  = _data[ 2];
			var _textS = _data[10];
			var _textF = _data[11];
			
			var _ang   = _data[ 3];
			var _pos   = _data[ 8];
			
			var _proj  = _data[ 4];
			var _fov   = _data[ 5];
			var _dist  = _data[ 6];
			var _sca   = _data[ 7];
			
			var _hgCol = _data[ 9];
			
			inputs[ 5].setVisible(_proj == 0);
			inputs[ 6].setVisible(_proj == 0);
			inputs[ 7].setVisible(_proj == 1);
			
			if(!is_surface(_higm)) return _outSurf;
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_heightmap_project_3d);
			shader_set_2( "dimension", _dim   );
			shader_set_s( "heightmap", _higm  );
			shader_set_s( "texture",   is_surface(_text)? _text : _higm );
			
			shader_set_s( "textureSide",      _textS  );
			shader_set_s( "textureFront",     _textF  );
			
			shader_set_i( "textureSide_use",  is_surface(_textS) );
			shader_set_i( "textureFront_use", is_surface(_textF) );
			
			shader_set_3( "angle",      _ang   );
			shader_set_3( "position",   _pos   );
			
			shader_set_i( "projection", _proj  );
			shader_set_f( "fov",        _fov   );
			shader_set_f( "distant",    _dist  );
			shader_set_f( "scale",      _sca   );
			
			shader_set_gradient(_hgCol);
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf; 
	}
} 
