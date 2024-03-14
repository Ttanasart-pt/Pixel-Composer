function Node_De_Stray(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "De-Stray";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Tolerance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 2] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 2;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 2,
		["Effect",	 false], 0, 1,
	]
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		surface_set_shader(_outSurf, sh_de_stray);
		shader_set_dim("dimension", _data[0]);
		shader_set_f("tolerance", _data[1]);
		
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}