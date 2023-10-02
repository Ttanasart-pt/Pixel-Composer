function Node_Alpha_Cutoff(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Alpha Cutoff";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Minimum", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2, "Any pixel with less alpha (more transparent) than this will be removed.")
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 2] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 3] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 4] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 4;
	
	input_display_list = [ 4, 
		["Output", 	 true], 0, 2, 3,
		["Cutoff",	false], 1, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region	
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		shader_set(sh_alpha_cutoff);
			shader_set_uniform_f(shader_get_uniform(sh_alpha_cutoff, "cutoff"), _data[1]);
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[2], _data[3]);
		
		return _outSurf;
	} #endregion
}