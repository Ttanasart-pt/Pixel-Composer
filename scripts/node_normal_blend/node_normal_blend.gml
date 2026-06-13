function Node_Normal_Blend(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blend Normal";
	
	////- =Blend
	newInput(10, nodeValue_EScroll( "Blend Mode", 0, [ 
		    "Additive",  "Maximum", 
		-1, "Substract", "Minimum", 
		-1, "Lerp"
	] ));
	newInput(11, nodeValue_Slider(  "Intensity",  1    ));
	newInput(13, nodeValue_Bool(    "Normalize",  true ));
	
	////- =Surface 1
	newInput( 0, nodeValue_Surface( "Normal 1" ));
	
		////- =/Transform
	newInput( 2, nodeValue_Vec2(    "Position 1", [0,0]   )).setUnitSimple();
	newInput( 3, nodeValue_Anchor(  "Anchor 1",   [.5,.5] ));
	newInput( 4, nodeValue_Rot(     "Rotation 1",   0     ));
	newInput( 5, nodeValue_Vec2(    "Scale 1",    [1,1]   ));
	
	////- =Surface 2
	newInput( 1, nodeValue_Surface( "Surface 2" ));
	
		////- =/Transform
	newInput( 6, nodeValue_Vec2(    "Position 2", [0,0]   )).setUnitSimple();
	newInput( 7, nodeValue_Anchor(  "Anchor 2",   [.5,.5] ));
	newInput( 8, nodeValue_Rot(     "Rotation 2",   0     ));
	newInput( 9, nodeValue_Vec2(    "Scale 2",    [1,1]   ));
	
	////- =Mask
	newInput(12, nodeValue_Surface( "Mask" ));
	// input 14
	 
	newOutput( 0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Blend",          false ], 10, 11, 13, 
		[ "Normal 1",       false ],  0, 
			[ "/Transform",  true ],  2,  3,  4,  5, 
		[ "Normal 2",       false ],  1, 
			[ "/Transform",  true ],  6,  7,  8,  9,  
		[ "Mask",           false ], 12, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _dim = getDimension();
		var _pos = getInputData( 6);
		var _anc = getInputData( 7);
		
		var _ax = _x + _anc[0] * _dim[0] * _s;
		var _ay = _y + _anc[1] * _dim[1] * _s;
		
		InputDrawOverlay(inputs[ 6].drawOverlay(w_hoverable, active, _ax, _ay, _s, _mx, _my));
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _mode  = _data[10];
			var _ints  = _data[11];
			var _norm  = _data[13];
			
			var _surf1 = _data[ 0];
			
			var _pos1  = _data[ 2];
			var _anc1  = _data[ 3];
			var _rot1  = _data[ 4];
			var _sca1  = _data[ 5];
			
			var _surf2 = _data[ 1];
			
			var _pos2  = _data[ 6];
			var _anc2  = _data[ 7];
			var _rot2  = _data[ 8];
			var _sca2  = _data[ 9];
			
			var _mask  = _data[ 12];
			
			if(!is_surface(_surf1)) return _outData;
		#endregion
		
		var _useS1 = is_surface(_surf1);
		var _useS2 = is_surface(_surf2);
		
		surface_set_shader(_outData, sh_blend_normal_map);
			shader_set_2( "dimension",     getDimension() );
			
			shader_set_i( "blendMode",     _mode  );
			shader_set_f( "intensity",     _ints  );
			shader_set_i( "renormalize",   _norm  );
			
			shader_set_s( "surface_1",     _surf1 );
			shader_set_i( "surface_1_use", _useS1 );
			
			shader_set_2( "position_1",    _pos1  );
			shader_set_2( "anchor_1",      _anc1  );
			shader_set_f( "rotation_1",    degtorad(_rot1) );
			shader_set_2( "scale_1",       _sca1  );
			
			shader_set_s( "surface_2",     _surf2 );
			shader_set_i( "surface_2_use", _useS2 );
			
			shader_set_2( "position_2",    _pos2  );
			shader_set_2( "anchor_2",      _anc2  );
			shader_set_f( "rotation_2",    degtorad(_rot2) );
			shader_set_2( "scale_2",       _sca2  );
			
			shader_set_s( "mask",          _mask  );
			shader_set_i( "mask_use",      is_surface(_mask) );
			
			draw_empty();
		surface_reset_shader();
		
		return _outData; 
	}
}