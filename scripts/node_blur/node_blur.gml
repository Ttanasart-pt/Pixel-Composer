function Node_Blur(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Blur";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[| 2] = nodeValue(2, "Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
		
	inputs[| 3] = nodeValue(3, "Override color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Replace all color while keeping the alpha. Used to\nfix grey outline when bluring transparent pixel.");
	
	inputs[| 4] = nodeValue(4, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [ 
		["Surface",	false],	0, 2, 
		["Blur",	false],	1, 3, 4, 
	];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _size  = _data[1];
		var _clamp = _data[2];
		var _isovr = _data[3];
		var _overc = _isovr? _data[4] : noone;
		
		inputs[| 4].setVisible(_isovr);
		
		surface_set_target(_outSurf);
		draw_clear_alpha(_isovr? _overc : 0, 0);
		BLEND_OVERRIDE
		draw_surface_safe(surface_apply_gaussian(_data[0], _size, false, c_white, _clamp, _overc), 0, 0);
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}