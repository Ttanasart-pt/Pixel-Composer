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
	newInput( 6, nodeValue_Slider(    "Size", .5 )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput( 8, nodeValue_Rotation( "Phase",  0 ));
	newInput( 9, nodeValue_Slider(   "Span",   1, [0, 2, .01] ));
	
	////- =Iteration
	newInput(10, nodeValue_Int(    "Iteration",   3 ));
	newInput(11, nodeValue_Slider( "Size Modify", 1, [0, 2, .01] ));
	newInput(12, nodeValue_Slider( "Span Modify", 1, [0, 2, .01] ));
	//input 13
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 5, 7, 
		["Surfaces",   true],  0,  1,  2,  3,  4,  
		["Fluff",     false],  6,  8,  9, 
		["Iteration", false], 10, 11, 12, 
	];
	
	temp_surface = [0,0];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { }
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		var _seed = _data[ 7];
		
		var _surf = _data[ 0];
		var _detl = _data[ 6];
		var _phas = _data[ 8];
		var _size = _data[ 9];
		
		var _itr  = _data[10]; _itr = max(1, _itr);
		var _idet = _data[11];
		var _isiz = _data[12];
		
		var _dim  = surface_get_dimension(_surf);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		var bg = 0;
		
		surface_set_shader(temp_surface[bg]);
			draw_surface_safe(_surf);
		surface_reset_shader();
			
		repeat(_itr) {
			bg = !bg;
			
			surface_set_shader(temp_surface[bg], sh_fluffify);
				shader_set_dim( "dimension", _surf );
				shader_set_f(   "seed",      _seed );
				
				shader_set_f(   "detail",    _detl );
				shader_set_f(   "phase",     degtorad(_phas) );
				shader_set_f(   "size",      _size );
				
				draw_surface_safe(temp_surface[!bg]);
			surface_reset_shader();
			
			_detl *= _idet;
			_size *= _isiz;
			_seed += 10;
		}
		
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[bg]);
		surface_reset_shader();
			
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[1], _data[2]);
		
		return _outSurf; 
	}
}