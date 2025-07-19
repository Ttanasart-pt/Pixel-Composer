function Node_Vignette(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Vignette";
	
	newActiveInput(1);
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	
	////- =Vignette
	newInput(5, nodeValue_Slider( "Roundness",  0  )).setMappable(7);
	newInput(2, nodeValue_Float(  "Exposure",   15 )).setMappable(8);
	newInput(3, nodeValue_Slider( "Strength",   1, [ 0, 2, 0.01 ] )).setMappable(9);
	newInput(4, nodeValue_Slider( "Exponent",  .25 ));
	
	////- =Render
	newInput(6, nodeValue_Bool( "Lighten", false ));
	// input 7
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		[ "Surfaces", false ], 0, 
		[ "Vignette", false ], 5, 7, 2, 8, 3, 9, 
		[ "Render",   false ], 6, 
	]
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		
		var _smot = _data[5];
		var _expo = _data[2];
		var _strn = _data[3];
		
		var _ligh = _data[6];
		
		surface_set_shader(_outSurf, sh_vignette);
			shader_set_f_map("smoothness", _smot, _data[7], inputs[5] );
			shader_set_f_map("exposure",   _expo, _data[8], inputs[2] );
			shader_set_f_map("strength",   _strn, _data[9], inputs[3] );
			
			shader_set_i("light",      _ligh );
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		return _outSurf;
	}
}