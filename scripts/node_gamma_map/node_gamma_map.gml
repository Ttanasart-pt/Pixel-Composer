function Node_Gamma_Map(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Gamma Map";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newInput(1, nodeValue_Bool("Invert", false));
	
	newActiveInput(2);
	
	input_display_list = [ 2, 0, 1, ];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) { #region
		
		surface_set_shader(_outSurf, sh_gamma_map);
			shader_set_i("invert", _data[1])
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}