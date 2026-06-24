function Node_Path_SDF(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Path to SDF";
	dimension_index = 1;
	
	newInput( 1, nodeValue_Dimension());
	
	////- =Path
	newInput( 0, nodeValue_Path( "Path" )).rejectArray();
	newInput( 9, nodeValue_Range(    "Path Range", [0,1] ));
	newInput(10, nodeValue_Slider(   "Path Shift",  0    ));
	newInput( 2, nodeValue_Int(      "Subdivision", 64   )).setValidator(VV_min(2)).rejectArray();
	
	////- =Transform
	newInput( 5, nodeValue_Vec2(     "Position",  [0,0]   )).setUnitSimple();
	newInput( 6, nodeValue_Anchor(   "Anchor",    [.5,.5] ));
	newInput( 7, nodeValue_Rot(      "Rotation",   0      ));
	newInput( 8, nodeValue_Vec2(     "Scale",     [1,1]   ));
	
	////- =Rendering
	newInput( 3, nodeValue_Float( "Max Distance", 16    ));
	newInput( 4, nodeValue_Bool(  "Inverted",     false ));
	// input 11
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1,
		[ "Path",      false ],  0,  9, 10,  2,
		[ "Transform", false ],  5,  6,  7,  8, 
		[ "Rendering", false ],  3,  4, 
	]
	
	attribute_surface_depth();
	
	temp_surface = [ noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dim  = _data[ 1];
			
			var _path = _data[ 0];
		    var _prng = _data[ 9];
		    var _pshf = _data[10];
			var _sub  = _data[ 2];
			
		    var _pos  = _data[ 5];
		    var _anc  = _data[ 6];
		    var _rot  = _data[ 7];
		    var _sca  = _data[ 8];
		    
			var _maxd = _data[ 3];
			var _inv  = _data[ 4];
		#endregion
		
		if(_path == noone) return _outSurf;
		
		var _p   = array_create((_sub + 1) * 2);
		var _isb = 1 / _sub;
		var _pp  = new __vec2P();
		
		for( var i = 0; i <= _sub; i++ ) {
			var _prog = frac(lerp(_prng[0], _prng[1], i * _isb) + _pshf);
			
			_pp = _path.getPointRatio(_prog, 0, _pp);
			_p[i * 2 + 0] = _pp.x;
			_p[i * 2 + 1] = _pp.y;
		}
		
		surface_set_shader(_outSurf, sh_path_sdf);
			shader_set_2( "dimension",   _dim  );
			
			shader_set_i( "subdivision", _sub  );
			shader_set_f( "points",      _p    );
			
			shader_set_f( "maxDistance", _maxd );
			shader_set_i( "inverted",    _inv  );
			
			shader_set_2( "position",    _pos  );
			shader_set_2( "anchor",      _anc  );
			shader_set_f( "rotation",    _rot  );
			shader_set_2( "scale",       _sca  );
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf;
	}
} 