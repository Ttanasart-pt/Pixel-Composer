function Node_Surface_Project_Volume_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name    = "Surface Project Volume 3D";
	is_3D   = NODE_3D.custom;
	lock_3D = false;
	
	newInput( 0, nodeValue_Dimension());
	
	////- =Surfaces
	newInput( 1, nodeValue_Surface( "Top"    )).setDrawGroup(0);
	newInput( 2, nodeValue_Surface( "Front"  )).setDrawGroup(0);
	newInput( 3, nodeValue_Surface( "Right"  )).setDrawGroup(0);
	
	////- =Volume
	newInput(10, nodeValue_Float( "Density",   10  ));
	newInput(11, nodeValue_Float( "Exponent",  2.5 ));
	
	////- =Camera
	newInput( 4, nodeValue_Vec3(    "View Angle",  [30, 45, 0]   ));
	newInput( 5, nodeValue_Vec3(    "Position",    [ 0,  0, 0]   ));
	newInput( 6, nodeValue_EButton( "Projection",   1 , [ "Perspective", "Orthographic" ] ));
	newInput( 7, nodeValue_Slider(  "FOV",          60, [1,90,1] ));
	newInput( 8, nodeValue_Float(   "Distance",     1            ));
	newInput( 9, nodeValue_Float(   "Scale",        3.46         ));
	
	////- =Rendering
	newInput(12, nodeValue_Color(    "Base Color",    ca_white  ));
	newInput(16, nodeValue_Gradient( "Density Color", gra_white ));
	newInput(14, nodeValue_Surface(  "Texture Side"             ));
	newInput(13, nodeValue_Range(    "Level",           [0,1]   ));
	newInput(15, nodeValue_Slider(   "Color Threshold", .5      ));
	// 17
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0,
		[ "Surfaces",  false ],  1,  2,  3, 
		[ "Volume",    false ], 10, 11, 
		[ "Camera",    false ],  4,  5,  6,  7,  8,  9, 
		[ "Rendering", false ], 12, 16, 14, 13, 15, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_interpolation();
	
	preview_data = undefined;
	
	static submitScene = function(_data, _viewDim = undefined, _viewAng = undefined, _viewDis = undefined) {
		#region data
			var _dim   = _data[ 0]; _viewDim = _viewDim ?? _dim;
			
			var _sTop  = _data[ 1];
			var _sFrn  = _data[ 2];
			var _sSid  = _data[ 3];
			
			var _dens  = _data[10];
			var _expo  = _data[11];
			
			var _ang   = _viewAng ?? _data[ 4];
			var _pos   = _data[ 5];
			var _proj  = _data[ 6];
			var _fov   = _data[ 7];
			var _dist  = _viewDis ?? _data[ 8];
			var _sca   = _viewDis ?? _data[ 9];
			
			var _bcol  = _data[12];
			var _dgra  = _data[16];
			var _tSid  = _data[14];
			var _level = _data[13];
			var _thrs  = _data[15];
			
			var isFrn = is_surface(_sFrn);
			var isSid = is_surface(_sSid);
			var isTop = is_surface(_sTop);
			
			if(!isFrn) _sFrn = isTop? _sTop : _sSid;
			if(!isSid) _sSid = isFrn? _sFrn : _sTop;
			if(!isTop) _sTop = isSid? _sSid : _sFrn;
		#endregion
		
		shader_set(sh_surface_project_volume_3d);
			shader_set_interpolation(_sTop);
			
			shader_set_2( "dimension", surface_get_dimension(_sFrn) );
			shader_set_2( "viewDimension", _viewDim );
			
			shader_set_s( "surTop",    _sFrn  );
			shader_set_s( "surFront",  _sSid  );
			shader_set_s( "surSide",   _sTop  );
			
			shader_set_s( "texSide",     _tSid  );
			shader_set_i( "texSide_use", is_surface(_tSid)  );
			
			shader_set_3( "angle",      _ang   );
			shader_set_3( "position",   _pos   );
			
			shader_set_i( "projection", _proj  );
			shader_set_f( "fov",        _fov   );
			shader_set_f( "distant",    _dist  );
			shader_set_f( "scale",      _sca   );
			
			shader_set_f( "density",    _dens  );
			shader_set_f( "exponent",   _expo  );
			
			shader_set_c( "baseColor",  _bcol  );
			shader_set_gradient(_dgra);
			shader_set_2( "level",      _level );
			shader_set_f( "threshold",  _thrs  );
			
			draw_empty();
		shader_reset();
		
	}
	
	static drawPreviewPanel = function(_panel) {
		if(preview_data == undefined) return;
		
		var _camera = _panel.d3_camera;
		submitScene(preview_data, [_panel.w, _panel.h], [ _camera.focus_angle_y, -_camera.focus_angle_x, 0 ], _camera.focus_dist);
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) {
		#region data
			var _dim   = _data[ 0];
			
			var _sTop  = _data[ 1];
			var _sFrn  = _data[ 2];
			var _sSid  = _data[ 3];
			
			var _dens  = _data[10];
			var _expo  = _data[11];
			
			var _ang   = _data[ 4];
			var _pos   = _data[ 5];
			var _proj  = _data[ 6];
			var _fov   = _data[ 7];
			var _dist  = _data[ 8];
			var _sca   = _data[ 9];
			
			var _bcol  = _data[12];
			var _tSid  = _data[14];
			var _level = _data[13];
			var _thrs  = _data[15];
			
			preview_data = _data;
			
			inputs[ 7].setVisible(_proj == 0);
			inputs[ 8].setVisible(_proj == 0);
			inputs[ 9].setVisible(_proj == 1);
			
			var isFrn = is_surface(_sFrn);
			var isSid = is_surface(_sSid);
			var isTop = is_surface(_sTop);
			
			if(!isFrn && !isSid && !isTop) return _outSurf;
		#endregion
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			submitScene(_data);
		surface_reset_target();
		
		return _outSurf; 
	}
} 
