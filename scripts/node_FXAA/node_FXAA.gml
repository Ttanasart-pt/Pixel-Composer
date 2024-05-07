function Node_FXAA(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "FXAA";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 2] = nodeValue("Distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	active_index = 1;
	
	input_display_list = [ 
		1, 0,
		["Effect", false], 2, 3, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region	
		surface_set_shader(_outSurf, sh_FXAA);
		gpu_set_tex_filter(true);
			shader_set_f("dimension", surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_f("cornerDis", _data[2]);
			shader_set_f("mixAmo",    _data[3]);
			
			draw_surface_safe(_data[0], 0, 0);
		gpu_set_tex_filter(false);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}