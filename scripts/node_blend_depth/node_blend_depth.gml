function Node_Blend_Depth(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blend Depth";
	
	////- =Surface 1
	newInput( 0, nodeValue_Surface( "Surface 1" )).setDrawGroup(0);
	newInput( 1, nodeValue_Surface( "Depth 1"   )).setDrawGroup(0);
	newInput( 4, nodeValue_Range(   "Depth Range 1", [0,1]   )).setDrawGroup(0);
	
		////- =/Transform
	newInput( 6, nodeValue_Vec2(    "Position 1", [0,0]   )).setUnitSimple();
	newInput( 7, nodeValue_Anchor(  "Anchor 1",   [.5,.5] ));
	newInput( 8, nodeValue_Rot(     "Rotation 1",   0     ));
	newInput( 9, nodeValue_Vec2(    "Scale 1",    [1,1]   ));
	
	////- =Surface 2
	newInput( 2, nodeValue_Surface( "Surface 2" )).setDrawGroup(1);
	newInput( 3, nodeValue_Surface( "Depth 2"   )).setDrawGroup(1);
	newInput( 5, nodeValue_Range(   "Depth Range 2", [0,1] )).setDrawGroup(1);
	
		////- =/Transform
	newInput(10, nodeValue_Vec2(    "Position 2", [0,0]   )).setUnitSimple();
	newInput(11, nodeValue_Anchor(  "Anchor 2",   [.5,.5] ));
	newInput(12, nodeValue_Rot(     "Rotation 2",   0     ));
	newInput(13, nodeValue_Vec2(    "Scale 2",    [1,1]   ));
	// input 14
	 
	newOutput( 0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone)).setDrawGroup(2);
	newOutput( 1, nodeValue_Output("Depth Out",   VALUE_TYPE.surface, noone)).setDrawGroup(2);
	
	input_display_list = [ 
		[ "Surface 1",      false ],  0,  1,  4, 
			[ "/Transform",  true ],  6,  7,  8,  9, 
		[ "Surface 2",      false ],  2,  3,  5, 
			[ "/Transform",  true ], 10, 11, 12, 13, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _dim = getDimension();
		var _pos = getInputData(10);
		var _anc = getInputData(11);
		
		var _ax = _x + _anc[0] * _dim[0] * _s;
		var _ay = _y + _anc[1] * _dim[1] * _s;
		
		InputDrawOverlay(inputs[10].drawOverlay(w_hoverable, active, _ax, _ay, _s, _mx, _my));
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _surf1 = _data[ 0];
			var _dept1 = _data[ 1];
			var _rang1 = _data[ 4];
			
			var _pos1  = _data[ 6];
			var _anc1  = _data[ 7];
			var _rot1  = _data[ 8];
			var _sca1  = _data[ 9];
			
			var _surf2 = _data[ 2];
			var _dept2 = _data[ 3];
			var _rang2 = _data[ 5];
			
			var _pos2  = _data[10];
			var _anc2  = _data[11];
			var _rot2  = _data[12];
			var _sca2  = _data[13];
			
			if(!is_surface(_surf1)) return _outData;
		#endregion
		
		var _useD1 = is_surface(_dept1);
		var _useD2 = is_surface(_dept2);

		var _useS1 = is_surface(_surf1);
		var _useS2 = is_surface(_surf2);
		
		surface_set_shader(_outData, sh_blend_depth);
			shader_set_2( "dimension",     getDimension() );
			
			shader_set_s( "surface_1",     _surf1 );
			shader_set_i( "surface_1_use", _useS1 );
			shader_set_s( "depth_1",       _dept1 );
			shader_set_i( "use_depth_1",   _useD1 );
			shader_set_2( "range_1",       _rang1 );
			
			shader_set_2( "position_1",    _pos1  );
			shader_set_2( "anchor_1",      _anc1  );
			shader_set_f( "rotation_1",    degtorad(_rot1) );
			shader_set_2( "scale_1",       _sca1  );
			
			shader_set_s( "surface_2",     _surf2 );
			shader_set_i( "surface_2_use", _useS2 );
			shader_set_s( "depth_2",       _dept2 );
			shader_set_i( "use_depth_2",   _useD2 );
			shader_set_2( "range_2",       _rang2 );
			
			shader_set_2( "position_2",    _pos2  );
			shader_set_2( "anchor_2",      _anc2  );
			shader_set_f( "rotation_2",    degtorad(_rot2) );
			shader_set_2( "scale_2",       _sca2  );
			
			draw_empty();
		surface_reset_shader();
		
		return _outData; 
	}
}