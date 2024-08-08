function Node_Blur_Simple(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Non-Uniform Blur";
	
	inputs[0] = nodeValue_Surface("Surface in", self);
	inputs[1] = nodeValue_Float("Size", self, 3)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 32, 0.1] });
	
	inputs[2] = nodeValue_Enum_Scroll("Oversample mode", self,  0, [ "Empty", "Clamp", "Repeat" ])
		.setTooltip("How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.");
	
	inputs[3] = nodeValue_Surface("Blur mask", self);
	
	inputs[4] = nodeValue_Bool("Override color", self, false, "Replace all color while keeping the alpha. Used to\nfix grey outline when bluring transparent pixel.");
	
	inputs[5] = nodeValue_Color("Color", self, c_black);
	
	inputs[6] = nodeValue_Surface("Mask", self);
	
	inputs[7] = nodeValue_Float("Mix", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[8] = nodeValue_Bool("Active", self, true);
		active_index = 8;
	
	inputs[9] = nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(6); // inputs 10, 11, 
	
	inputs[12] = nodeValue_Gradient("Gradient", self, new gradientObject([ cola(c_black), cola(c_white) ]))
		.setMappable(13);
	
	inputs[13] = nodeValueMap("Gradient map", self);
	
	inputs[14] = nodeValueGradientRange("Gradient map range", self, inputs[1]);
	
	inputs[15] = nodeValue_Bool("Use Gradient", self, false);
	
	inputs[16] = nodeValue_Bool("Gamma Correction", self, false);
	
	input_display_list = [ 8, 9, 
		["Surfaces", true],	0, 6, 7, 10, 11, 
		["Blur",	false],	1, 3, 4, 5, 16, 
		["Effects",	false, 15],	12, 13, 14, 
	];
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_oversample();
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[12].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region	
		if(!is_surface(_data[0])) return _outSurf;
		var _size	= _data[1];
		var _samp	= struct_try_get(attributes, "oversample");
		var _mask	= _data[3];
		var _isovr  = _data[4];
		var _overc  = _data[5];
		var _msk    = _data[6];
		var _mix    = _data[7];
		var _useGrd = _data[15];
		var _gam    = _data[16];
		
		inputs[5].setVisible(_isovr);
		
		surface_set_shader(_outSurf, sh_blur_simple);
			shader_set_i("useGradient", _useGrd);
			shader_set_gradient(_data[12], _data[13], _data[14], inputs[12]);
		
			shader_set_f("dimension",  surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_f("size",       _size);
			shader_set_i("sampleMode", _samp);
			shader_set_i("gamma",      _gam);
			
			shader_set_i("overrideColor", _isovr);
			shader_set_color("overColor", _overc);
			
			shader_set_i("useMask",    is_surface(_mask));
			shader_set_surface("mask", _mask);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _msk, _mix);
		_outSurf = channel_apply(_data[0], _outSurf, _data[9]);
		
		return _outSurf;
	} #endregion
}