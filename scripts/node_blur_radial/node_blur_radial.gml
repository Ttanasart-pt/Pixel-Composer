function Node_Blur_Radial(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Radial Blur";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 45)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 2] = nodeValue("Center",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		
	inputs[| 3] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
		
	inputs[| 4] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 5] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 6] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 6;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 6, 
		["Surfaces", true],	0, 4, 5, 
		["Blur",	false],	1, 2,
	];
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var pos = getInputData(2);
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 1].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny);
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {		
		var _str = _data[1];
		var _cen = _data[2];
		var _mask = _data[4];
		var _mix  = _data[5];
		
		_cen = array_clone(_cen);
		_cen[0] /= surface_get_width_safe(_outSurf);
		_cen[1] /= surface_get_height_safe(_outSurf);
		
		surface_set_shader(_outSurf, sh_blur_radial);
			shader_set_interpolation(_data[0]);
			shader_set_f("dimension", surface_get_width_safe(_outSurf), surface_get_height_safe(_outSurf));
			shader_set_f("strength", abs(_str));
			shader_set_f("center", _cen);
			
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		
		return _outSurf;
	}
}