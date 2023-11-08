function Node_Invert(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Invert";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 2] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 3;
	
	input_display_list = [ 3, 
		["Surfaces",	 true], 0, 1, 2, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region	
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		shader_set(sh_invert);
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		
		return _outSurf;
	} #endregion
}