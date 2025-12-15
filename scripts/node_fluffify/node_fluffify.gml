function Node_Fluffify(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Fluffify";
	
	newActiveInput(5);
	newInput( 7, nodeValueSeed());
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface("Surface In"));
	newInput( 1, nodeValue_Surface( "Mask" ));
	newInput( 2, nodeValue_Slider(  "Mix", 1));
	__init_mask_modifier(1, 3); // inputs 3, 4
	
	////- =Fluff
	newInput(16, nodeValue_EScroll(  "Shape",  0, [ "Circle", "Diamond", "Square", "Surface" ] ));
	newInput(27, nodeValue_Surface(  "Surface" ));
	newInput( 6, nodeValue_Slider(   "Size",   1, [0, 2, .01] )).setUnitSimple();
	newInput( 9, nodeValue_Slider(   "Radius", 1, [0, 2, .01] )).setMappable(15);
	newInput( 8, nodeValue_Rotation( "Phase",  0              ));
	
	////- =Iteration
	newInput(10, nodeValue_Float(    "Iteration",     10             ));
	newInput(11, nodeValue_Slider(   "Size Modify",   1, [0, 2, .01] ));
	newInput(12, nodeValue_Slider(   "Span Modify",   1, [0, 2, .01] ));
	newInput(20, nodeValue_Vec2(     "Offset",       [0,0]           ));
	
	////- =Rendering
	newInput(13, nodeValue_EScroll(  "Blend Mode", 0, [ "Maximum", "Override" ] ));
	newInput(21, nodeValue_Slider(   "Substractive",         0       ));
	newInput(22, nodeValue_Bool(     "Blend Original",       false   ));
	newInput(14, nodeValue_Bool(     "Fade by Iteration",    false   ));
	newInput(17, nodeValue_Bool(     "Skip First Iteration", false   ));
	
	////- =Coloring
	newInput(18, nodeValue_Palette(  "Iteration Blend", [ ca_white ] ));
	newInput(23, nodeValue_Bool(     "Stretch Palette",      true    ));
	newInput(19, nodeValue_Int(      "Blend Period",         1       ));
	
	////- =Decorner
	newInput(24, nodeValue_Bool(     "Use Decorner",   true ));
	newInput(25, nodeValue_Slider(   "Tolerance",      0    ));
	//input 28
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 5, 7, 
		[ "Surfaces",   true     ],  0,  1,  2,  3,  4,  
		[ "Fluff",     false     ], 16, 27,  6,  9,  8, 15, 
		[ "Iteration", false     ], 10, 11, 12, 20, 
		[ "Rendering", false     ], 13, 21, 22, 14, 17, 
		[ "Coloring",  false     ], 18, 23, 19, 
		[ "Decorner",   true, 24 ], 25, 
	];
	
	temp_surface = [0,0,0,0,0];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[20].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		var _seed = _data[ 7];
		
		var _surf = _data[ 0];
		var _detl = _data[ 6];
		var _phas = _data[ 8];
		var _size = _data[ 9];
		
		var _shap = _data[16];
		var _itr  = _data[10]; _itr  = max(0.01, _itr);
		var _idet = _data[11]; _idet = power(_idet, 1 / _itr);
		var _isiz = _data[12]; _isiz = power(_isiz, 1 / _itr);
		var _offs = _data[20];
		
		var _blnd = _data[13];
		var _subs = _data[21];
		var _bori = _data[22];
		var _fItr = _data[14];
		var _skpf = _data[17];
		
		var _iBlnd = _data[18], _palLen = array_length(_iBlnd);
		var _palSt = _data[23];
		var _pBlnd = _data[19]; _pBlnd = max(_pBlnd, 1);
		
		var _decorn      = _data[24];
		var _decornThres = _data[25];
		
		inputs[19].setVisible(!_palSt);
		
		var _dim  = surface_get_dimension(_surf);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
			surface_clear(temp_surface[i]);
		}
		
		var _maxItr = _itr;
		var bg      = 0;
		var _i      = 0;
		var _mulp   = 1;
		var _ofs    = [0,0];
		
		if(_palSt) _pBlnd = ceil(_maxItr) / _palLen;
		
		surface_set_shader(temp_surface[bg]);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		random_set_seed(_seed);
		
		while(_itr >= 0) {
			bg = !bg;
			
			surface_set_shader(temp_surface[bg], sh_fluffify);
				shader_set_2(   "dimension",    _dim             );
				shader_set_f(   "seed",         _seed            );
				
				shader_set_f(   "iteration",    _i + 1           );
				shader_set_f(   "maxIteration", ceil(_maxItr)    );
				
				shader_set_i(     "shape",       _shap                                  );
				shader_set_f(     "detail",      _detl                                  );
				shader_set_f(     "phase",       degtorad(_phas)                        );
				shader_set_2(     "offset",      [_ofs[0] / _maxItr, _ofs[1] / _maxItr] );
				shader_set_f_map( "size",        _size, _data[15], inputs[9]            );
				shader_set_f(     "sizeMultiply", _mulp * min(_itr, 1)                  );
				
				shader_set_i(   "blend",         _blnd );
				shader_set_f(   "substract",     _subs );
				shader_set_i(   "fadeIteration", _fItr );
				shader_set_i(   "skipFirst",     _skpf );
				
				draw_surface_safe(temp_surface[!bg]);
			surface_reset_shader();
			
			if(_decorn) {
				surface_set_shader(temp_surface[4], sh_de_corner);
					shader_set_f( "dimension", _dim         );
					shader_set_f( "tolerance", _decornThres );
					shader_set_i( "strict",    0            );
					shader_set_i( "inner",     true         );
					shader_set_i( "side",      true         );
					
					draw_surface_safe(temp_surface[bg]);
				surface_reset_shader();
				
				var _temp = temp_surface[bg];
				temp_surface[bg] = temp_surface[4];
				temp_surface[4]  = _temp;
			}
			
			var cindex = floor(_i / _pBlnd);
			
			surface_set_shader(temp_surface[2 + bg], noone);
				if(!_bori) shader_set(sh_fluffify_apply);
				draw_surface_ext_safe(temp_surface[bg], 0, 0, 1, 1, 0, _iBlnd[cindex % _palLen]);
				if(!_bori) shader_reset();
				
				draw_surface_safe(temp_surface[2 + !bg], 0, 0);
			surface_reset_shader();
			
			_detl *= _idet;
			_mulp *= _isiz;
			_seed += pi;
			
			_ofs[0] += _offs[0];
			_ofs[1] += _offs[1];
			
			_itr--;
			_i++;
		}
			
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[2 + bg]);
		surface_reset_shader();
	
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[1], _data[2]);
		
		return _outSurf; 
	}
}