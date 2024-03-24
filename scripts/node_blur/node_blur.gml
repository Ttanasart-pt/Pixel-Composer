function Node_Blur(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blur";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	inputs[| 1] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 3)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 1, 32, 0.1 ] });
	
	inputs[| 2] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
		
	inputs[| 3] = nodeValue("Override color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Replace all color while keeping the alpha. Used to\nfix grey outline when bluring transparent pixel.");
	
	inputs[| 4] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 5] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 6] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 7;
	
	inputs[| 8] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(5); // inputs 9, 10
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 7, 8, 
		["Surfaces", true],	0, 5, 6, 9, 10, 
		["Blur",	false],	1, 3, 4, 
	];
	
	attribute_surface_depth();
	attribute_oversample();
	surface_blur_init();
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region		
		var _size  = _data[1];
		var _clamp = struct_try_get(attributes, "oversample");
		var _isovr = _data[3];
		var _mask  = _data[5];
		var _mix   = _data[6];
		var _overc = _isovr? _data[4] : noone;
		
		inputs[| 4].setVisible(_isovr);
		
		surface_set_target(_outSurf);
			draw_clear_alpha(_isovr? _overc : 0, 0);
			BLEND_OVERRIDE;
			draw_surface_safe(surface_apply_gaussian(_data[0], _size, false, c_white, _clamp, _overc), 0, 0);
			BLEND_NORMAL;
		surface_reset_target();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		_outSurf = channel_apply(_data[0], _outSurf, _data[8]);
		
		return _outSurf;
	} #endregion
}