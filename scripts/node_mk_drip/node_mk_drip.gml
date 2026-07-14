function Node_MK_Drip(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Drip";
	
	newInput( 3, nodeValueSeed());
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 1, nodeValue_Surface( "Mask"       ));
	
	////- =Source
	newInput( 2, nodeValue_Float(    "Density",     5    ));
	newInput( 9, nodeValue_Vec2(     "Offset",     [0,0] ));
	newInput(15, nodeValue_Slider(   "Randomness",  1    ));
	newInput(18, nodeValue_SliRange( "Level",     [0,1] ));
	
	////- =Fluid
	newInput(23, nodeValue_EScroll(  "Type",       0, [ "Linear", "Point" ] ));
	newInput( 4, nodeValue_Rotation( "Direction", -90             ));
	newInput(24, nodeValue_Vec2(     "Center",    [.50,.50]       )).setUnitSimple();
	newInput( 5, nodeValue_Range(    "Distance",  [.25,.25], true )).setMappableConst(19);
	newInput( 6, nodeValue_Range(    "Thickness", [.20,.20], true )).setCurvable( 7, CURVE_DEF_11 );
	newInput( 8, nodeValue_Range(    "Threshold", [.20,.20], true ));
	
	////- =Drip
	newInput(10, nodeValue_Bool(     "Dripping",   false ));
	newInput(11, nodeValue_Float(    "Frequency",  2     ));
	newInput(12, nodeValue_Range(    "Amplitude", [.2,.2], true )).setCurvable(16, CURVE_DEF_11 );
	newInput(13, nodeValue_Float(    "Phase",      0     ));
	newInput(14, nodeValue_Float(    "Speed",      1     ));
	
	////- =Blobify
	newInput(22, nodeValue_Bool(     "Use Blobify", 0    ));
	newInput(20, nodeValue_Float(    "Blobify",     4    ));
	newInput(21, nodeValue_Slider(   "Threshold",  .5    ));
	
	////- =Rendering
	newInput(17, nodeValue_Color(    "Blend",   ca_white ));
	// 25
	
	newOutput( 0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 
		[ "Surface",   false     ],  0,  1, 
		[ "Source",    false     ],  2,  9, 15, 18, 
		[ "Fluid",     false     ], 23,  4, 24,  5, 19,  6,  7,  8,
		[ "Dripping",  false, 10 ], 11, 12, 16, 13, 14, 
		[ "Blobify",   false, 22 ], 20, 21, 
		[ "Rendering", false     ], 17, 
	];
	
	////- Nodes
	
	temp_surface = [ noone, noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _type = getInputSingle(23);
		
		if(_type == 1) drawOverlayInput(inputs[24].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _seed  = _data[ 3];
			
			var _surf  = _data[ 0];
			var _mask  = _data[ 1];
			
			var _dens  = _data[ 2];
			var _offs  = _data[ 9];
			var _rand  = _data[15];
			var _levl  = _data[18];
			
			var _type  = _data[23];
			var _dirr  = _data[ 4];
			var _pont  = _data[24];
			
			var _dist  = _data[ 5];
			var _distM = _data[19];
			var _thck  = _data[ 6];
			var _thckC = _data[ 7];
			var _thrs  = _data[ 8];
			
			var _drip  = _data[10];
			var _freq  = _data[11];
			var _ampl  = _data[12];
			var _amplC = _data[16];
			var _phas  = _data[13];
			var _sped  = _data[14];
			
			var _bUse  = _data[22];
			var _blob  = _data[20];
			var _bThr  = _data[21];
			
			var _colr  = _data[17];
			
			inputs[ 4].setVisible(_type == 0);
			inputs[24].setVisible(_type == 1);
			
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		update_on_frame = _drip;
		
		var _dim = surface_get_dimension(_surf);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		surface_set_shader(temp_surface[0], sh_mk_drip_cell);
			shader_set_2( "dimension", _dim  );
			
			shader_set_f( "seed",       _seed );
			shader_set_f( "randomness", _rand );
			
			shader_set_f( "scale",     _dens );
			shader_set_2( "offset",    _offs );
			shader_set_2( "level",     _levl );
			
			draw_surface( _surf, 0, 0 );
		surface_reset_shader();
		
		surface_set_shader(temp_surface[1], sh_mk_drip);
			shader_set_2( "dimension",     _dim   );
			shader_set_s( "original",      _surf  );
			shader_set_f( "seed",          _seed  );
			
			shader_set_i( "dripType",      _type  );
			shader_set_f( "dripDirection", _dirr  );
			shader_set_f( "dripCenter",    _pont  );
			
			shader_set_2( "dripDistance",     _dist  );
			shader_set_i( "dripDistanceUseMap", inputs[5].attributes.mapped );
			shader_set_s( "dripDistanceMap",  _distM );
			
			shader_set_2( "dripThreshold", _thrs  );
			shader_set_2( "thickness",     _thck  );
			shader_set_curve( "thickness", _thckC );
			
			shader_set_i( "dripping",      _drip  );
			shader_set_f( "dripFreq",      _freq  );
			shader_set_2( "dripAmpli",     _ampl  );
			shader_set_curve( "dripAmpli", _amplC );
			shader_set_f( "dripPhase",     _phas  );
			shader_set_f( "dripTime",      _sped * CURRENT_FRAME / TOTAL_FRAMES );
			
			draw_surface( temp_surface[0], 0, 0 );
		surface_reset_shader();
		
		if(_bUse) {
			surface_set_shader(temp_surface[2], sh_mk_drip_round);
				shader_set_2( "dimension",  _dim   );
				shader_set_f( "radius",     _blob  );
				shader_set_f( "threshold",  _bThr  );
				
				draw_surface( temp_surface[1], 0, 0 );
			surface_reset_shader();
			
		} else {
			surface_set_shader(temp_surface[2]);
				draw_surface( temp_surface[1], 0, 0 );
			surface_reset_shader();
			
		}
		
		surface_set_shader(_outSurf, sh_sample, true, BLEND.normal);
			draw_surface_ext( temp_surface[2], 0, 0, 1, 1, 0, _colr, 1);
			draw_surface( _surf, 0, 0 );
		surface_reset_shader();
		
		return _outSurf;
	}
}