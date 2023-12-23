function Node_Threshold(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Threshold";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Brightness", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
		
	inputs[| 2] = nodeValue("Brightness Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(13);
		
	inputs[| 3] = nodeValue("Brightness Smoothness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 4] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 5] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 6] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 6;
	
	inputs[| 7] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 8] = nodeValue("Alpha Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(14);
		
	inputs[| 9] = nodeValue("Alpha Smoothness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 10] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(4); // inputs 11, 12
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 13] = nodeValueMap("Brightness map", self);
	
	inputs[| 14] = nodeValueMap("Alpha map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 6, 10, 
		["Surfaces",	 true], 0, 4, 5, 11, 12, 
		["Threshold",	false], 1, 2, 13, 3, 7, 8, 14, 9, 
	];
	
	attribute_surface_depth();
	
	static step = function() { #region
		var _bright = getInputData(1);
		inputs[| 2].setVisible(_bright);
		inputs[| 3].setVisible(_bright);
		
		var _alpha  = getInputData(7);
		inputs[| 8].setVisible(_alpha);
		inputs[| 9].setVisible(_alpha);
		
		__step_mask_modifier();
		
		inputs[| 2].mappableStep();
		inputs[| 8].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		
		surface_set_shader(_outSurf, sh_threshold);
			shader_set_i("bright",			    _data[1]);
			shader_set_f_map("brightThreshold", _data[2], _data[13], inputs[| 2]);
			shader_set_f("brightSmooth",	    _data[3]);
			
			shader_set_i("alpha",			    _data[7]);
			shader_set_f_map("alphaThreshold",  _data[8], _data[14], inputs[| 8]);
			shader_set_f("alphaSmooth",		    _data[9]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[4], _data[5]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[10]);
		
		return _outSurf;
	} #endregion
}
