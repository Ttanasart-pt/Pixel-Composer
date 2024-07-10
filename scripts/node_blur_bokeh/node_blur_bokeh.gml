function Node_Blur_Bokeh(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Lens Blur";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 0.01] })
		.setMappable(8);
	
	inputs[| 2] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 3] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 4] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 4;
	
	inputs[| 5] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(2); // inputs 6, 7
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 8] = nodeValueMap("Strength map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	input_display_list = [ 4, 5, 
		["Surfaces", true], 0, 2, 3, 6, 7, 
		["Blur",	false], 1, 8, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[| 1].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		
		surface_set_shader(_outSurf, sh_blur_bokeh);
			shader_set_f("dimension", surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_f_map("strength", _data[1], _data[8], inputs[| 1]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[2], _data[3]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[5]);
		
		return _outSurf;
	} #endregion
}