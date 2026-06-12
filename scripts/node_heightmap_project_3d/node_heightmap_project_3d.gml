function Node_Heightmap_Project_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name    = "Heightmap Project 3D";
	is_3D   = NODE_3D.custom;
	lock_3D = false;
	
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
	newInput(12, nodeValue_Range(   "Height Range", [0,1]        ));
	
	////- =Rendering
	newInput(14, nodeValue_Bool(     "Tiled",        false       ));
	newInput( 9, nodeValue_Gradient( "Height Color", gra_white   ));
	newInput(13, nodeValue_Range(    "Depth Range",   [0,1]      ));
	// 15
	
	newOutput( 0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone )).setDrawGroup(10);
	newOutput( 1, nodeValue_Output("Depth Pass",  VALUE_TYPE.surface, noone )).setDrawGroup(10);
	newOutput( 2, nodeValue_Output("Normal Pass", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 0,
		[ "Surfaces",  false ],  1,  2, 10, 11, 
		[ "Camera",    false ],  3,  8,  4,  5,  6,  7, 12, 
		[ "Rendering", false ], 14,  9, 13, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_interpolation();
	
	preview_data = undefined;
	
	static submitScene = function(_data, _viewDim = undefined, _viewAng = undefined, _viewDis = undefined) {
		#region data
			var _dim   = _data[ 0]; _viewDim = _viewDim ?? _dim;
			
			var _higm  = _data[ 1];
			var _text  = _data[ 2];
			var _textS = _data[10];
			var _textF = _data[11];
			
			var _ang   = _viewAng ?? _data[ 3];
			var _pos   = _data[ 8];
			
			var _proj  = _data[ 4];
			var _fov   = _data[ 5];
			var _dist  = _viewDis ?? _data[ 6];
			var _sca   = _viewDis ?? _data[ 7];
			var _hsca  = _data[12];
			
			var _tile  = _data[14];
			var _hgCol = _data[ 9];
			var _depth = _data[13];
		#endregion
		
		shader_set(sh_heightmap_project_3d);
			shader_set_interpolation(_higm);
			
			shader_set_2( "dimension",     _dim     );
			shader_set_2( "viewDimension", _viewDim );
			
			shader_set_s( "heightmap",     _higm    );
			shader_set_s( "texture",       is_surface(_text)? _text : _higm );
			
			shader_set_s( "textureSide",      _textS  );
			shader_set_s( "textureFront",     _textF  );
			
			shader_set_i( "textureSide_use",  is_surface(_textS) );
			shader_set_i( "textureFront_use", is_surface(_textF) );
			
			shader_set_3( "angle",      _ang   );
			shader_set_3( "position",   _pos   );
			
			shader_set_i( "projection", _proj  );
			shader_set_f( "fov",        _fov   );
			shader_set_f( "distant",    _dist  );
			
			shader_set_i( "tiled",      _tile  );
			shader_set_f( "scale",      _sca   );
			shader_set_2( "depthRange", _depth );
			shader_set_2( "heightScale",_hsca  );
			
			shader_set_gradient(_hgCol);
			
			draw_empty();
		shader_reset();
		
	}
	
	static drawPreviewPanel = function(_panel) {
		if(preview_data == undefined) return;
		
		var _camera = _panel.d3_camera;
		submitScene(preview_data, [_panel.w, _panel.h], [ _camera.focus_angle_y, -_camera.focus_angle_x, 0 ], _camera.focus_dist);
	}
	
	static processData = function(_outData, _data, _array_index = 0) {
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
			var _hsca  = _data[12];
			
			var _hgCol = _data[ 9];
			
			preview_data = _data;
			
			inputs[ 5].setVisible(_proj == 0);
			inputs[ 6].setVisible(_proj == 0);
			inputs[ 7].setVisible(_proj == 1);
			
			if(!is_surface(_higm)) return _outData;
		#endregion
		
		surface_set_target_ext(0, _outData[0]);
		surface_set_target_ext(1, _outData[1]);
		surface_set_target_ext(2, _outData[2]);
			DRAW_CLEAR
			submitScene(_data);
		surface_reset_target();
		
		return _outData; 
	}
} 
