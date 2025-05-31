function Node_Vignette(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Vignette";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newActiveInput(1);
	
	newInput(2, nodeValue_Float("Exposure", 15));
	
	newInput(3, nodeValue_Slider("Strength", 1, [ 0, 2, 0.01 ] ));
	
	newInput(4, nodeValue_Slider("Exponent", 0.25));
	
	newInput(5, nodeValue_Slider("Roundness", 0));
	
	newInput(6, nodeValue_Bool("Lighten", false))
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		["Surfaces", false], 0, 
		["Vignette", false], 5, 2, 3, 
		["Render",	 false], 6, 
	]
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) { #region
		surface_set_shader(_outSurf, sh_vignette);
			shader_set_f("exposure",   _data[2]);
			shader_set_f("strength",   _data[3]);
			shader_set_f("amplitude",  _data[4]);
			shader_set_f("smoothness", _data[5]);
			shader_set_i("light",      _data[6]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}