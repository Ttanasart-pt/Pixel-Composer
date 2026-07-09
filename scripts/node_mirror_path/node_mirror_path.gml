function Node_Mirror_Path(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Mirror Path";
	
	newActiveInput(5);
	newInput( 6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 1, nodeValue_Surface( "Mask"       ));
	newInput( 2, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(1, 3); // inputs 3, 4
	
	////- =Path
	newInput( 7, nodeValue_Path(  "Path"              ));
	newInput( 8, nodeValue_Int(   "Resolution", 16    ));
	newInput( 9, nodeValue_Bool(  "Loop",       false ));
	
	////- =Mirror
	newInput(10, nodeValue_EButton( "Side",  0, [ "Left", "Right", "Both" ] ));
	// 11
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [  5,  6,  
		[ "Surface", false ],  0,  1,  2,  3,  4,  
		[ "Path",    false ],  7,  8,  9, 
		[ "Mirror",  false ], 10, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation(false, true);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			
			var _path = _data[ 7];
			var _reso = _data[ 8];
			var _loop = _data[ 9];
			
			var _both = _data[10];
			
			if(!is_path(_path)) return _outSurf;
		#endregion
		
		var _points = array_create(_reso * 2);
		var __p = new __vec2P();
		
		var _stp = _loop? 1 / _reso : 1 / (_reso - 1);
		if(_loop) _reso++;
		for( var i = 0; i < _reso; i++ ) {
			var prg = i * _stp;
			
			__p = _path.getPointRatio(prg, 0, __p);
			_points[i * 2 + 0] = __p.x;
			_points[i * 2 + 1] = __p.y;
		}
		
		surface_set_shader(_outSurf, sh_mirror_path);
			shader_set_interpolation( _surf );
			shader_set_2( "dimension", surface_get_dimension(_surf));
			
			shader_set_i( "resolution", _reso   );
			shader_set_f( "points",     _points );
			
			shader_set_i( "side",       _both   );
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply_input(_surf, _outSurf, _data[1], _data[2], inputs[1]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf; 
	}
}