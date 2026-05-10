function Node_RM_Terrain(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RM Terrain";
	
	newInput( 0, nodeValue_Dimension());
	
	////- =Extrusion
	newInput( 1, nodeValue_Surface( "Surface"                 ));
	newInput( 9, nodeValue_Slider(  "Height", 1, [0,4,.01]    ));
	newInput(10, nodeValue_Bool(    "Tile",   true            ));
	
	////- =Textures
	newInput(11, nodeValue_Surface( "Texture"                 ));
	newInput(13, nodeValue_Surface( "Reflection"              ));
	
	////- =Transform
	newInput( 2, nodeValue_Vec3(   "Position", [0,0,0]        ));
	newInput( 3, nodeValue_Vec3(   "Rotation", [30,45,0]      ));
	newInput( 4, nodeValue_Slider( "Scale", 1, [0,4,.01]      ));
	
	////- =Camera
	newInput( 5, nodeValue_Slider( "FOV",        30, [0,90,1] ));
	newInput( 6, nodeValue_Vec2(   "View Range", [0,6]        ));
	
	////- =Render
	newInput(12, nodeValue_Color(  "Background", ca_black     ));
	newInput( 7, nodeValue_Slider( "BG Bleed",   1            ));
	newInput( 8, nodeValue_Color(  "Ambient",    ca_white     ));
	
	////- =Light
	newInput(14, nodeValue_Vec3(   "Sun Position", [.5,1,.5]  ));
	newInput(15, nodeValue_Slider( "Shadow",        .2        ));
	// 16
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0,
		[ "Extrusion", false ],  1,  9, 10,
		[ "Textures",  false ], 11, 13, 
		[ "Transform", false ],  2,  3,  4, 
		[ "Camera",    false ],  5,  6, 
		[ "Render",    false ], 12,  7,  8,
		[ "Light",     false ], 14, 15, 
	];
	
	////- Node
	
	temp_surface = [ noone, noone, noone, noone ];
	
	static processData = function(_outSurf, _data, _array_index = 0) {
		#region data
			var _dim  = _data[ 0];
			
			var _surf = _data[ 1];
			var _thk  = _data[ 9];
			var _tile = _data[10];
			
			var _text = _data[11];
			var _refl = _data[13];
			
			var _pos  = _data[ 2];
			var _rot  = _data[ 3];
			var _sca  = _data[ 4];
			
			var _fov  = _data[ 5];
			var _rng  = _data[ 6];
			
			var _bgc  = _data[12];
			var _dpi  = _data[ 7];
			var _amb  = _data[ 8];
			
			var _sun  = _data[14];
			var _sha  = _data[15];
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++)
			temp_surface[i] = surface_verify(temp_surface[i], 4192, 4192);
		
		var tx = 1024;
		surface_set_shader(temp_surface[0]);
			draw_surface_stretched_safe(_surf, tx * 0, tx * 0, tx, tx);
			draw_surface_stretched_safe(_text, tx * 1, tx * 0, tx, tx);
			draw_surface_stretched_safe(_refl, tx * 2, tx * 0, tx, tx);
		surface_reset_shader();
		
		surface_set_shader(_outSurf, sh_rm_terrain);
		gpu_set_texfilter(true);
			for (var i = 0, n = array_length(temp_surface); i < n; i++)
				shader_set_surface($"texture{i}", temp_surface[i]);
			
			shader_set_i( "shape",       1     );
			shader_set_i( "tile",        _tile );
			shader_set_i( "useTexture",  is_surface(_text) );
			shader_set_3( "position",    _pos  );
			shader_set_3( "rotation",    _rot  );
			shader_set_f( "objectScale", _sca  );
			shader_set_f( "thickness",   _thk  );
			
			shader_set_f( "fov",         _fov  );
			shader_set_2( "viewRange",   _rng  );
			shader_set_f( "depthInt",    _dpi  );
			
			shader_set_3( "sunPosition", _sun  );
			shader_set_f( "shadow",      _sha  );
			
			shader_set_c( "background",  _bgc  );
			shader_set_c( "ambient",     _amb  );
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf; 
	}
} 
