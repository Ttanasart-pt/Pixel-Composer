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
	newInput( 5, nodeValue_EButton( "Type",       0, [ "Scale", "Continuous", "Gradient" ] ));
	newInput(21, nodeValue_Gradient("Gradient",   gra_black_white ));
	newInput( 1, nodeValue_Vec2(    "Center",   [.5,.5] )).hideLabel().setHotkey("G").setUnitSimple().setPieMenu();
	newInput( 2, nodeValue_Slider(  "Strength",   1, [-16, 16, .01] )).setHotkey("S").setMappable(4).setCurvable(19).setPieMenu();
	newInput( 6, nodeValue_Slider(  "Intensity",  1, [  0,  4, .01] )).setHotkey("I").setMappable(7).setPieMenu();
	newInput(15, nodeValue_Slider(  "Shift",      0, [ -1,  1, .01] )).setMappable(16);
	newInput(17, nodeValue_Slider(  "Scale",      1, [  0, 16, .01] )).setMappable(18);
	
	////- =Processing
	newInput(20, nodeValue_Int( "Iteration",  1  ));
	newInput(14, nodeValue_Int( "Resolution", 64 ));
	// input 22
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 3, 
		[ "Surface",    false ],  0,  8,  9, 10, 11, 12, 13, 
		[ "Effect",     false ],  5, 21,  1,  2,  4, 19,  6,  7, 15, 16, 17, 18,
		[ "Processing", false ], 20, 14, 
	];
	
	////- Node
	attribute_surface_depth();
	attribute_interpolation();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		drawOverlayInput(inputs[1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, 1  ));
		drawOverlayInput(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my     ));
		drawOverlayInput(inputs[6].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, 90, _dim[1] / 4 ));
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _surf = _data[ 0];
			var _cent = _data[ 1];
			var _type = _data[ 5];
			var _grad = _data[21];
			
			var _iter = _data[20];
			var _reso = _data[14];
			
			inputs[21].setVisible(_type == 2);
			
			inputs[15].setVisible(_type == 1 || _type == 2);
			inputs[17].setVisible(_type == 1 || _type == 2);
			
			inputs[20].setVisible(_type == 0);
			inputs[14].setVisible(_type == 1 || _type == 2);
		#endregion
		
		var sh = sh_chromatic_aberration;
		switch(_type) {
			case 0 : sh = sh_chromatic_aberration;      break;
			case 1 : sh = sh_chromatic_aberration_cont; break;
			case 2 : sh = sh_chromatic_aberration_grad; break;
		}
		
		surface_set_shader(_outSurf, sh);
			shader_set_interpolation(_surf);
			shader_set_uv(_data[8], _data[9]);
			
			shader_set_dim("dimension",   _surf );
			shader_set_2("center",        _cent );
			shader_set_gradient(_grad);
			
			shader_set_f_map("strength",  _data[ 2], _data[ 4], inputs[ 2], _data[19] );
			shader_set_f_map("intensity", _data[ 6], _data[ 7], inputs[ 6] );
			shader_set_f_map("chromaShf", _data[15], _data[16], inputs[15] );
			shader_set_f_map("chromaSca", _data[17], _data[18], inputs[17] );
			
			shader_set_f("resolution",    _reso );
			shader_set_i("iteration",     _iter );
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[10], _data[11]);
		
		return _outSurf;
	}
}