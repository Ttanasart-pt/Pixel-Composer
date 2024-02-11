function Node_Gamma_Map(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Gamma Map";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Invert", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 2] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 2;
	
	input_display_list = [ 2, 0, 1, ];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		
		surface_set_shader(_outSurf, sh_gamma_map);
			shader_set_i("invert", _data[1])
			
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}