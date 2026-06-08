function Node_Surface_Project_3D(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Surface Project 3D";
	is_3D = NODE_3D.custom;
	
	newInput( 0, nodeValue_Dimension());
	
	////- =Surfaces
	newInput( 1, nodeValue_Surface( "Top"    )).setDrawGroup(0);
	newInput( 2, nodeValue_Surface( "Front"  )).setDrawGroup(0);
	newInput( 3, nodeValue_Surface( "Right"  )).setDrawGroup(0);
	
		////- =/Back side
	newInput( 5, nodeValue_Surface( "Bottom" )).setDrawGroup(1).setVisible(true, false);
	newInput( 6, nodeValue_Surface( "Back"   )).setDrawGroup(1).setVisible(true, false);
	newInput( 7, nodeValue_Surface( "Left"   )).setDrawGroup(1).setVisible(true, false);
	
	////- =Camera
	newInput( 4, nodeValue_Vec3(    "View Angle",  [30, 45, 0]   ));
	newInput(12, nodeValue_Vec3(    "Position",    [ 0,  0, 0]   ));
	newInput( 9, nodeValue_EButton( "Projection",   1 , [ "Perspective", "Orthographic" ] ));
	newInput(10, nodeValue_Slider(  "FOV",          60, [1,90,1] ));
	newInput(11, nodeValue_Float(   "Distance",     2            ));
	newInput( 8, nodeValue_Float(   "Scale",        3.46         ));
	
	////- =Geometry
	newInput(13, nodeValue_Bool(    "Extrude Both Side", true ));
	
		////- =/Noise
	newInput(18, nodeValue_Bool(   "Use Noise",  false ));
	newInput(19, nodeValueSeed(,   "Noise Seed"        ));
	newInput(20, nodeValue_Slider( "Threshold",  .5    ));
	
	////- =Rendering
	newInput(16, nodeValue_EScroll( "Color Type",    0, [ "Face Normal", "Face Average All", "Face Average Except"  ] ));
	newInput(15, nodeValue_Palette( "Face Blending", [ca_white]       ));
	newInput(17, nodeValue_EButton( "Except",        0, ["X","Y","Z"] ));
	newInput(14, nodeValue_Range(   "Depth Range",   [0,1]            ));
	// 21
	
	newOutput( 0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone )).setDrawGroup(10);
	newOutput( 1, nodeValue_Output("Depth Pass",  VALUE_TYPE.surface, noone )).setDrawGroup(10);
	newOutput( 2, nodeValue_Output("Normal Pass", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 0,
		[ "Surfaces",          false ],  1,  2,  3, 
			[ "/Back Texture", false ],  5,  6,  7, 
		[ "Camera",            false ],  4, 12,  9, 10, 11,  8,
		[ "Geometry",          false ], 13, 
			[ "/Noise",     true, 18 ], 19, 20, 
		[ "Rendering",         false ], 16, 15, 17, 14, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_interpolation();
	
	temp_surface = [ noone ];
	preview_data = undefined;
	
	static submitScene = function(_data, _viewDim = undefined, _viewAng = undefined, _viewDis = undefined) {
		#region data
			var _dim   = _data[ 0]; _viewDim = _viewDim ?? _dim;
			
			var _sTop  = _data[ 1];
			var _sFrn  = _data[ 2];
			var _sSid  = _data[ 3];
			
			var _sTopb = _data[ 5];
			var _sFrnb = _data[ 6];
			var _sSidb = _data[ 7];
			
			var _ang   = _viewAng ?? _data[ 4];
			var _pos   = _data[12];
			var _proj  = _data[ 9];
			var _fov   = _data[10];
			var _dist  = _viewDis ?? _data[11]; 
			var _sca   = _viewDis ?? _data[ 8]; 
			
			var _bothS = _data[13];
			
			var _nsUse  = _data[18];
			var _nsSeed = _data[19];
			var _nsThr  = _data[20];
			
			var _blndT = _data[16];
			var _fblnd = _data[15];
			var _blndX = _data[17];
			var _depth = _data[14];
		#endregion
		
		shader_set(sh_surface_project_3d);
			shader_set_interpolation(_sTop);
			
			shader_set_2( "dimension",     _dim             );
			shader_set_2( "viewDimension", _viewDim         );
			shader_set_s( "axisSurfaces",  temp_surface[0]  );
			
			shader_set_i( "surTopB_use",   is_surface(_sFrnb) );
			shader_set_i( "surFrontB_use", is_surface(_sSidb) );
			shader_set_i( "surSideB_use",  is_surface(_sTopb) );
			
			shader_set_3( "angle",      _ang   );
			shader_set_3( "position",   _pos   );
			
			shader_set_i( "projection", _proj  );
			shader_set_f( "fov",        _fov   );
			shader_set_f( "distant",    _dist  );
			shader_set_f( "scale",      _sca   );
			
			shader_set_i( "bothSide",   _bothS );
			
			shader_set_i( "noiseUse",   _nsUse  );
			shader_set_f( "noiseSeed",  _nsSeed );
			shader_set_f( "noiseThres", _nsThr  );
			
			shader_set_i( "blendType",  _blndT );
			shader_set_i( "blendFaceEx",_blndX );
			shader_set_palette( _fblnd );
			shader_set_2( "depthRange", _depth );
			
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
			
			var _bothS = _data[13];
			
			var _blndT = _data[16];
			var _fblnd = _data[15];
			var _blndX = _data[17];
			var _depth = _data[14];
			
			inputs[10].setVisible(_proj  == 0);
			inputs[11].setVisible(_proj  == 0);
			inputs[ 8].setVisible(_proj  == 1);
			
			inputs[15].setVisible(_blndT == 0);
			inputs[17].setVisible(_blndT == 2);
			
			preview_data = _data;
			
			var isFrn = is_surface(_sFrn);
			var isSid = is_surface(_sSid);
			var isTop = is_surface(_sTop);
			
			if(!isFrn && !isSid && !isTop) return _outData;
		#endregion
		
		if(!isFrn) _sFrn = isTop? _sTop : _sSid;
		if(!isSid) _sSid = isFrn? _sFrn : _sTop;
		if(!isTop) _sTop = isSid? _sSid : _sFrn;
		
		var _dimF = surface_get_dimension(_sFrn);
		var _dimS = surface_get_dimension(_sSid);
		var _dimT = surface_get_dimension(_sTop);
		
		var _dimMax = [ max(_dimF[0], _dimS[0], _dimT[0]), max(_dimF[1], _dimS[1], _dimT[1]) ];
		
		temp_surface[0] = surface_verify(temp_surface[0], _dimMax[0] * 3, _dimMax[1] * 3);
		surface_set_shader(temp_surface[0]);
			draw_surface_safe(_sFrn,  _dimMax[0] * 0, _dimMax[1] * 0);
			draw_surface_safe(_sSid,  _dimMax[0] * 1, _dimMax[1] * 0);
			draw_surface_safe(_sTop,  _dimMax[0] * 2, _dimMax[1] * 0);
			
			draw_surface_safe(_sFrnb, _dimMax[0] * 0, _dimMax[1] * 1);
			draw_surface_safe(_sSidb, _dimMax[0] * 1, _dimMax[1] * 1);
			draw_surface_safe(_sTopb, _dimMax[0] * 2, _dimMax[1] * 1);
			
		surface_reset_shader();
		
		surface_set_target_ext(0, _outData[0]);
		surface_set_target_ext(1, _outData[1]);
		surface_set_target_ext(2, _outData[2]);
			DRAW_CLEAR
			submitScene(_data);
		surface_reset_target();
		
		return _outData; 
	}
} 
