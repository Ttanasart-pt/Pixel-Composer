function Node_Gradient_Path(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Gradient Path";
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput( 1, nodeValue_Surface( "Mask" ));
	
	////- =Gradient
	newInput( 2, nodeValue_Gradient( "Gradient", gra_black_white )).setHotkeyAuto("C").setMappable(3).setPieMenu();
	newInput( 5, nodeValue_Slider(   "Shift",    0, [-2,2,.01]   )).setMappable(6).setPieMenu();
	newInput( 7, nodeValue_Slider(   "Scale",    1, [ 0,5,.01]   )).setHotkey("S").setMappable(8).setPieMenu();
	newInput( 9, nodeValue_EButton(  "Loop",     0, [ "None", "Loop", "Pingpong" ] ));
	
	////- =Path
	newInput(10, nodeValue_Path(     "Path"              ));
	newInput(11, nodeValue_Range(    "Range",      [0,1] ));
	newInput(12, nodeValue_Slider(   "Shift",       0    ));
	newInput(13, nodeValue_Bool(     "Invert",     false ));
	newInput(15, nodeValue_Int(      "Resolution", 32    ));
	
	////- =Shape
	newInput(14, nodeValue_EScroll(  "Type",  0, [ "Along Path", "Distance" ] ));
	// 16
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Output",   false ],  0,  1, 
		[ "Gradient", false ],  2,  3,  5,  6,  7,  8,  9,  
		[ "Path",     false ], 10, 11, 12, 13, 15, 
		[ "Shape",    false ], 14, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		drawOverlayInput(inputs[10].drawOverlay( w_hoverable, active, _x, _y, _s, _mx, _my ));
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _dim  = _data[ 0];
			var _msk  = _data[ 1];
			
			var _grad = _data[ 2];
			var _shif = _data[ 5];
			var _scal = _data[ 7];
			var _lop  = _data[ 9];
			
			var _path = _data[10];
			var _prng = _data[11];
			var _pshf = _data[12];
			var _pinv = _data[13];
			var _pres = _data[15];
			
			var _type = _data[14];
			
			if(!is_path(_path)) return _outSurf;
		#endregion
		
		var _pathPoints = array_create(_pres + 1);
		var _st = 1 / _pres;
		var __p = new __vec2P();
		
		for( var i = 0; i <= _pres; i++ ) {
			var _prog = frac(clamp(i * _st, 0., 0.999) + _pshf);
			    _prog = clamp(_prog, 0., 0.999);
			if(_pinv) _prog = 1 - _prog;
			
			var _samp = lerp(_prng[0], _prng[1], _prog);
			
			_path.getPointRatio(_samp, 0, __p);
			// print(i, _samp, __p)
			
			_pathPoints[i * 2 + 0] = __p.x / _dim[0];
			_pathPoints[i * 2 + 1] = __p.y / _dim[1];
		}
		
		surface_set_shader(_outSurf, sh_gradient_path);
			shader_set_gradient(_grad, _data[ 3], _data[ 4], inputs[ 2]);
			
			shader_set_2( "dimension",     _dim  );
			shader_set_s( "mask",          _msk  );
			shader_set_i( "useMask",       is_surface(_msk) );
			
			shader_set_i( "gradient_loop", _lop  );
			shader_set_i( "type",          _type );
			
			shader_set_m( "shift",  _shif, _data[6], inputs[5] );
			shader_set_m( "scale",  _scal, _data[7], inputs[7] );
			
			shader_set_f( "pathPoints",    _pathPoints );
			shader_set_i( "pathRes",       _pres       );
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf; 
	}
}