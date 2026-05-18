function Node_Fur(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name   = "Fur";
	shader = sh_fur;
	
	newInput( 4, nodeValueSeed());
	
	////- =Output
	newInput( 0, nodeValue_Dimension());
	newInput( 1, nodeValue_Surface(  "UV Map"    ));
	newInput( 2, nodeValue_Slider(   "UV Mix", 1 ));
	newInput( 3, nodeValue_Surface(  "Mask"      ));
	
	////- =Fur
	newInput( 5, nodeValue_Float(    "Density",    32   )).setPieMenu();
	newInput( 6, nodeValue_Int(      "Fur Amount", 2    )).setPieMenu();
	newInput( 7, nodeValue_Range(    "Length",    [2,4] )).setMappableConst(21).setPieMenu();
	
	////- =Direction
	newInput( 8, nodeValue_Rotation( "Direction", -90   )).setMappableConst(14).setPieMenu();
	newInput(13, nodeValue_Float(    "Wiggle",    10    )).setPieMenu();
	
	////- =Transform
	newInput(15, nodeValue_Vec2(    "Position", [0,0]   )).setUnitSimple();
	newInput(16, nodeValue_Rotation("Rotation",  0      ));
	newInput(17, nodeValue_Vec3(    "Scale",    [1,1]   ));
	
	////- =Shape
	newInput( 9, nodeValue_Slider(   "Thickness", .7    )).setCurvable(20, CURVE_DEF_01, "Curve");
	
	////- =Render
	newInput(18, nodeValue_Color(    "BG Color",  ca_black  ));
	newInput(10, nodeValue_Color(    "Color",     ca_white  ));
	newInput(11, nodeValue_Surface(  "Texture"              ));
	newInput(12, nodeValue_Slider(   "Shadow",    1         ));
	newInput(19, nodeValue_Slider(   "Edge",      0         ));
	// 22
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 4, 
		[ "Output",     true ],  0,  1,  2,  3, 
		[ "Fur",       false ],  5,  7, 21, 
		[ "Direction", false ],  8, 14, 13, 
		[ "Transform", false ], 15, 16, 17, 
		[ "Shape",     false ],  9, 20, 
		[ "Render",    false ], 18, 10, 11, 12, 19, 
	];
	
	////- Nodes
	
	temp_surface = [ noone ];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var pos = getInputSingle(15);
		var px  = _x + pos[0] * _s;
		var py  = _y + pos[1] * _s;
		
		InputDrawOverlay(inputs[15].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		InputDrawOverlay(inputs[16].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
	}
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _seed  = _data[ 4];
			var _dim   = _data[ 0];
			var _mask  = _data[ 3];
			
			var _dens  = _data[ 5];
			var _subd  = _data[ 6];
			var _len   = _data[ 7], _lenUseMap = inputs[ 7].attributes.mapped;
			var _lenm  = _data[21];
			
			var _ang   = _data[ 8], _angUseMap = inputs[ 8].attributes.mapped;
			var _angm  = _data[14];
			var _wigg  = _data[13];
			
			var _pos   = _data[15];
			var _rot   = _data[16];
			var _sca   = _data[17];
			
			var _thk   = _data[ 9];
			var _thkC  = _data[20];
			
			var _bgcol = _data[18];
			var _col   = _data[10];
			var _csamp = _data[11];
			var _sha   = _data[12];
			var _edge  = _data[19];
			
			inputs[21].setVisible(_lenUseMap, _lenUseMap);
			inputs[14].setVisible(_angUseMap, _angUseMap);
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
		
		var _useLmap = _lenUseMap && is_surface(_lenm);
		var _useAmap = _angUseMap && is_surface(_angm);
		if(_useAmap) {
			surface_set_shader(temp_surface[0], sh_fur_direction_map);
				shader_set_2( "dimension", _dim );
				draw_surface(_angm, 0, 0);
			surface_reset_shader();
		}
		
		surface_set_shader(_outSurf, sh_fur);
			shader_set_uv(_data[1], _data[2]);
			shader_set_i( "usemask", is_surface(_mask) );
			shader_set_s( "mask",    _mask );
			
			shader_set_2( "dimension",      _dim   );
			
			shader_set_2( "position",       _pos   );
			shader_set_f( "rotation",       _rot   );
			shader_set_2( "scale",          _sca   );
			
			shader_set_f( "density",         _dens    );
			shader_set_i( "furDens",         _subd    );
			shader_set_2( "furLengthRange",  _len     );
			shader_set_s( "furLengthMap",    _lenm    );
			shader_set_i( "usefurLengthMap", _useLmap );
			
			shader_set_f( "furAngle",       _ang     );
			shader_set_s( "furAngleMap",    temp_surface[0] );
			shader_set_i( "usefurAngleMap", _useAmap );
			shader_set_f( "furAngleRange",  _wigg    );
			
			shader_set_f( "thickness",      _thk   );
			shader_set_curve( "thickC",     _thkC  );
			
			shader_set_c( "bgcolor",        _bgcol );
			shader_set_c( "color",          _col   );
			shader_set_i( "usecolorSample", is_surface(_csamp) );
			shader_set_s( "colorSample",    _csamp );
			shader_set_f( "shadow",         _sha   );
			shader_set_f( "edgeBlend",      _edge  );
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf; 
	}
}