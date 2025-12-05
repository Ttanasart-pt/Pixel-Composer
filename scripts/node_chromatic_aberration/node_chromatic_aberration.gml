function Node_Chromatic_Aberration(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Chromatic Aberration";
	
	newActiveInput(3);
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In" ));
	newInput( 8, nodeValue_Surface( "UV Map"     ));
	newInput( 9, nodeValue_Slider(  "UV Mix", 1  ));
	newInput(10, nodeValue_Surface( "Mask"       ));
	newInput(11, nodeValue_Slider(  "Mix",    1  ));
	__init_mask_modifier(10, 12); // inputs 12, 13, 
	
	////- =Effect
	newInput( 5, nodeValue_EButton( "Type",       0, [ "RGB", "Continuous" ] ));
	newInput( 1, nodeValue_Vec2(    "Center",   [.5,.5] )).hideLabel().setHotkey("G").setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput( 2, nodeValue_Slider(  "Strength",   1, [-16, 16, 0.01] )).setHotkey("S").setMappable(4).setCurvable(19);
	newInput( 6, nodeValue_Slider(  "Intensity",  1, [  0,  4, 0.01] )).setHotkey("I").setMappable(7);
	newInput(15, nodeValue_Slider(  "Shift",      0, [ -1,  1, 0.01] )).setMappable(16);
	newInput(17, nodeValue_Slider(  "Scale",      1, [  0, 16, 0.01] )).setMappable(18);
	
	////- =Processing
	newInput(14, nodeValue_Int( "Resolution", 64 ));
	// input 20
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 
		[ "Surface",    false ], 0, 8, 9, 10, 11, 12, 13, 
		[ "Effect",     false ], 5, 1, 2, 4, 19, 6, 7, 15, 16, 17, 18,
		[ "Processing", false ], 14, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny, 1  ));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny     ));
		InputDrawOverlay(inputs[6].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny, 90, _dim[1] / 4 ));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[ 0];
		var _cent = _data[ 1];
		var _type = _data[ 5];
		var _reso = _data[14];
		
		var _sCurveUse = inputs[2].attributes.curved;
		var _sCurve    = _data[19];
		
		inputs[15].setVisible(_type == 1);
		inputs[17].setVisible(_type == 1);
		
		surface_set_shader(_outSurf, sh_chromatic_aberration);
			shader_set_interpolation(_surf);
			shader_set_uv(_data[8], _data[9]);
			
			shader_set_f("resolution",    _reso );
			shader_set_dim("dimension",   _surf );
			shader_set_i("type",          _type );
			shader_set_2("center",        _cent );
			shader_set_f_map("strength",  _data[ 2], _data[ 4], inputs[ 2] );
			shader_set_f_map("intensity", _data[ 6], _data[ 7], inputs[ 6] );
			shader_set_f_map("chromaShf", _data[15], _data[16], inputs[15] );
			shader_set_f_map("chromaSca", _data[17], _data[18], inputs[17] );
			
			shader_set_i("s_curve_use",   _sCurveUse);
			shader_set_curve("s",         _sCurve);
		
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[10], _data[11]);
		
		return _outSurf;
	}
}