function Node_Blur_Bokeh(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Lens Blur";
	
	shader = sh_blur_bokeh;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_str = shader_get_uniform(shader, "strength");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 0.01] });
	
	inputs[| 2] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 3] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 4] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 4;
	
	input_display_list = [ 4, 
		["Output", 	 true], 0, 2, 3, 
		["Blur",	false], 1,
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _str  = _data[1];
		var _mask = _data[2];
		var _mix  = _data[3];
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE;
			
			shader_set(shader);
			shader_set_uniform_f(uniform_dim, surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_uniform_f(uniform_str, _str);
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL;
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		
		return _outSurf;
	} #endregion
}