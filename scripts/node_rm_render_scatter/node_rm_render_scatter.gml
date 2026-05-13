function Node_RM_Render_Scatter(_x, _y, _group = noone) : Node_RM(_x, _y, _group) constructor {
	name  = "RM Render Scatter";
	
	newInput( 0, nodeValue_Dimension());
	newInput(18, nodeValueSeed());
	
	////- =Object
	newInput(13, nodeValue_SDF( "SDF Object" )).setVisible(true, true);
	
	////- =Scatter
	newInput(17, nodeValue_Vec2(    "Grid",         [4,4]   ));
	newInput(19, nodeValue_Vec2(    "Offset",       [0,0]   ));
	newInput(11, nodeValue_Vec3(    "Rotation Min", [0,0,0] ));
	newInput(20, nodeValue_Vec3(    "Rotation Max", [0,0,0] ));
	newInput(12, nodeValue_Range(   "Scale",        [1,1]   ));
	
	////- =Camera
	newInput(21, nodeValue_Vec3(    "Camera Rotation", [30,45,0]      ));
	newInput(23, nodeValue_Slider(  "Camera Scale",     1, [0,4,0.01] ));
	newInput( 1, nodeValue_EButton( "Projection",       0, [ "Perspective", "Orthographic" ] ));
	newInput( 2, nodeValue_Slider(  "FOV",              30, [0,90,1]  ));
	newInput( 3, nodeValue_Float(   "Ortho Scale",      5             ))
	newInput( 4, nodeValue_Vec2(    "View Range",       [1,10]        ));
	
	////- =/Depth
	newInput(22, nodeValue_Vec2(    "Depth Range",      [1,10]        ));
	newInput( 5, nodeValue_Slider(  "Depth",            0             ));
	
	////- =Background
	newInput( 6, nodeValue_Bool(    "Draw BG",          false        ));
	newInput( 7, nodeValue_Color(   "Background",       ca_black     ));
	newInput(10, nodeValue_Surface( "Environment"                    ));
	newInput(14, nodeValue_Bool(    "Env Interpolation", false       ));
	newInput( 8, nodeValue_Slider(  "Ambient Level",    .2           ));
	
	////- =Light
	newInput(24, nodeValue_Bool(    "Use Light",         true        ));
	newInput( 9, nodeValue_Vec3(    "Position",         [-.4,-.5,1]  ));
	newInput(16, nodeValue_Float(   "Intensity",         1           ));
	newInput(15, nodeValue_Color(   "Color",             ca_white    ));
	// 25
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	
	input_display_list = [  0, 18, 
		[ "Object",     false ], 13, 
		[ "Scatter",    false ], 17, 19, 11, 20, 12, 
		[ "Camera",     false ], 21, 23,  1,  2,  3,  4, 
			[ "/Depth", false ], 22,  5, 
		[ "Background", false ],  6,  7, 10, 14,  8, 
		[ "Light",  false, 24 ],  9, 16, 15, 
	];
	
	////- Node
	
	static drawOverlay3D = function(active, _mx, _my, _params) {
		var _panel = _params[$ "panel"] ?? noone;
		
		#region draw result
			var _outSurf = outputs[0].getValue();
			if(is_array(_outSurf)) _outSurf = array_safe_get_fast(_outSurf, 0);
			if(!is_surface(_outSurf)) return;
			
			var _w = _panel.w;
			var _h = _panel.h - _panel.toolbar_height;
			var _pw = surface_get_width_safe(_outSurf);
			var _ph = surface_get_height_safe(_outSurf);
			var _ps = ui(128) / max(_ph, _pw);
			
			var _pws = _pw * _ps;
			var _phs = _ph * _ps;
			
			var _px = _w - ui(8) - _pws;
			var _py = _h - ui(8) - _phs;
			
			draw_surface_ext_safe(_outSurf, _px, _py, _ps, _ps);
			draw_set_color(COLORS._main_icon);
			draw_rectangle(_px, _py, _px + _pws, _py + _phs, true);
		#endregion
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) {
		#region data
			var _dim  = _data[ 0];
			var _seed = _data[18];
			
			var _shp  = _data[13];
			
			var _grid = _data[17];
			var _pos  = _data[19];
			var _rotn = _data[11];
			var _rotx = _data[20];
			var _scal = _data[12];
			
			var _crot = _data[21];
			var _csal = _data[23];
			var _pro  = _data[ 1];
			var _fov  = _data[ 2];
			var _ort  = _data[ 3];
			var _vrn  = _data[ 4];
			
			var _depR = _data[22];
			var _dep  = _data[ 5];
			
			var _bgd  = _data[ 6];
			var _enc  = _data[ 7];
			var _env  = _data[10];
			var _eint = _data[14];
			var _amb  = _data[ 8];
			
			var _luse = _data[24];
			var _lig  = _data[ 9];
			var _lInt = _data[16];
			var _lCol = _data[15];
			
			inputs[3].setVisible(_pro == 1);
			
			if(!is(_shp, RM_Object)) return _outSurf;
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		var txs = attributes.texture_size;
		temp_surface[0] = surface_verify(temp_surface[0], txs, txs);
		temp_surface[1] = surface_verify(temp_surface[1], txs, txs);
		
		#region object
			var tx = 1024;
			surface_set_shader(temp_surface[0]);
				gpu_set_tex_filter(_eint);
				draw_surface_stretched_safe(_env, tx * 0, tx * 0, tx, tx);
				gpu_set_tex_filter(false);
			surface_reset_shader();
		
	 		object = _shp;
			object.flatten();
			object.setTexture(temp_surface[1]);
			
			environ.surface    = temp_surface[0];
			environ.bgEnv      = _env;
			environ.envFilter  = _eint;
			
			environ.projection = _pro;
			environ.fov        = _fov;
			environ.orthoScale = _ort;
			environ.viewRange  = _vrn;
			
			environ.depthRange = _depR;
			environ.depthInt   = _dep;
			
			environ.bgColor    = _enc;
			environ.bgDraw     = _bgd;
			environ.ambInten   = _amb;
			
			environ.useLight   = _luse;
			environ.light      = _lig;
			environ.lightInten = _lInt;
			environ.lightColor = _lCol;
		#endregion
		
		surface_set_shader(_outSurf, sh_rm_render_scatter);
		gpu_set_texfilter(getAttribute("interpolate") > 1);
			shader_set_f( "seed",           _seed );
			shader_set_2( "dimension",      _dim  );
			
			shader_set_2( "grid",           _grid );
			shader_set_2( "positionOffset", _pos  );
			shader_set_3( "rotationMin",    _rotn );
			shader_set_3( "rotationMax",    _rotx );
			shader_set_2( "objScale",       _scal );
			
			shader_set_3( "camRotation",    _crot );
			shader_set_f( "camScale",       _csal  );
			shader_set_f( "camRatio",       _dim[0] / _dim[1] );
			
			environ.apply();
			object.apply();
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf; 
	}
}