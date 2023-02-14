function Node_Blur(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Blur";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[| 2] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
		
	inputs[| 3] = nodeValue("Override color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Replace all color while keeping the alpha. Used to\nfix grey outline when bluring transparent pixel.");
	
	inputs[| 4] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 5] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 6] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 7] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 7;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 7,
		["Surface",	 true],	0, 2, 5, 6, 
		["Blur",	false],	1, 3, 4, 
	];
	
	surface_blur_init();
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {		
		var _size  = _data[1];
		var _clamp = _data[2];
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
		
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		
		return _outSurf;
	}
}