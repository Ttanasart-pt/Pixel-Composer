function Node_Blur_Slope(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Slope Blur";
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue_Float("Strength", self, 4)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 1, 32, 0.1 ] })
		.setMappable(9);
	
	inputs[| 2] = nodeValue_Surface("Slope Map",   self);
	
	inputs[| 3] = nodeValue_Surface("Mask", self);
	
	inputs[| 4] = nodeValue_Float("Mix", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue_Bool("Active", self, true);
		active_index = 5;
	
	inputs[| 6] = nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(3); // inputs 7, 8
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[|  9] = nodeValueMap("Strength map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 10] = nodeValue_Float("Step", self, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 1, 0.01] });
		
	inputs[| 11] = nodeValue_Bool("Gamma Correction", self, false);
	
	input_display_list = [ 5, 6, 
		["Surfaces", true], 0, 3, 4, 7, 8, 
		["Blur",	false], 2, 1, 9, 10, 11, 
	]
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[| 1].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		surface_set_shader(_outSurf, sh_blur_slope);
			shader_set_interpolation(_data[0]);
			shader_set_f("dimension",      surface_get_dimension(_data[0]));
			shader_set_f_map("strength",   _data[1], _data[ 9], inputs[| 1]);
			shader_set_f("stepSize",       _data[10]);
			shader_set_surface("slopeMap", _data[2]);
			shader_set_f("slopeMapDim",    surface_get_dimension(_data[2]));
			shader_set_i("sampleMode",	  struct_try_get(attributes, "oversample"));
			shader_set_i("gamma",          _data[11]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	} #endregion
}