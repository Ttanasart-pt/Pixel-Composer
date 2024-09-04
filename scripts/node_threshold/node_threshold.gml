function Node_Threshold(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Threshold";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Bool("Brightness", self, false));
		
	newInput(2, nodeValue_Float("Brightness Threshold", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(13);
		
	newInput(3, nodeValue_Float("Brightness Smoothness", self, 0))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(4, nodeValue_Surface("Mask", self));
	
	newInput(5, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(6, nodeValue_Bool("Active", self, true));
		active_index = 6;
	
	newInput(7, nodeValue_Bool("Alpha", self, false));
	
	newInput(8, nodeValue_Float("Alpha Threshold", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(14);
		
	newInput(9, nodeValue_Float("Alpha Smoothness", self, 0))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(10, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(4); // inputs 11, 12
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(13, nodeValueMap("Brightness map", self));
	
	newInput(14, nodeValueMap("Alpha map", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 6, 10, 
		["Surfaces",	 true], 0, 4, 5, 11, 12, 
		["Brightness",	 true, 1], 2, 13, 3,
		["Alpha",	     true, 7], 8, 14, 9, 
	];
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[2].mappableStep();
		inputs[8].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		
		surface_set_shader(_outSurf, sh_threshold);
			shader_set_i("bright",			    _data[1]);
			shader_set_f_map("brightThreshold", _data[2], _data[13], inputs[2]);
			shader_set_f("brightSmooth",	    _data[3]);
			
			shader_set_i("alpha",			    _data[7]);
			shader_set_f_map("alphaThreshold",  _data[8], _data[14], inputs[8]);
			shader_set_f("alphaSmooth",		    _data[9]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[4], _data[5]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[10]);
		
		return _outSurf;
	} #endregion
}
