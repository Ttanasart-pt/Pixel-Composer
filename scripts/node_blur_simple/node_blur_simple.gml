function Node_Blur_Simple(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Non-Uniform Blur";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 32, 1] });
	
	inputs[| 2] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
	
	inputs[| 3] = nodeValue("Blur mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 4] = nodeValue("Override color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Replace all color while keeping the alpha. Used to\nfix grey outline when bluring transparent pixel.");
	
	inputs[| 5] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 6] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 7] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 8] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 8;
	
	inputs[| 9] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(6); // inputs 10, 11, 
	
	input_display_list = [ 8, 9, 
		["Surfaces", true],	0, 6, 7, 10, 11, 
		["Blur",	false],	1, 3, 4, 5, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_oversample();
	
	static step = function() { #region
		__step_mask_modifier();
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
		
		inputs[| 5].setVisible(_isovr);
		
		surface_set_shader(_outSurf, sh_blur_simple);
			shader_set_f("dimension",  surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_f("size",       _size);
			shader_set_i("sampleMode", _samp);
			
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