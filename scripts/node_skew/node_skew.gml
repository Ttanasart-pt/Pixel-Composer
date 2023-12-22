function Node_Skew(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Skew";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue("Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, ["x", "y"]);
	
	inputs[| 2] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] })
		.setMappable(12);
		
	inputs[| 3] = nodeValue("Wrap", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 4] = nodeValue("Center", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0] )
		.setDisplay(VALUE_DISPLAY.vector, { side_button : button(function() { centerAnchor(); })
															.setIcon(THEME.anchor)
															.setTooltip(__txt("Set to center")) });
	
	inputs[| 5] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
	
	inputs[| 6] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 7] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 8] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 8;
	
	inputs[| 9] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(6); // inputs 10, 11
	
	inputs[| 12] = nodeValue("Strength map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(false, false);
	
	input_display_list = [ 8, 9, 
		["Surfaces", true],	0, 6, 7, 10, 11, 
		["Skew",	false],	1, 2, 12, 4,
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static centerAnchor = function() { #region
		if(!is_surface(current_data[0])) return;
		var ww = surface_get_width_safe(current_data[0]);
		var hh = surface_get_height_safe(current_data[0]);
		
		inputs[| 4].setValue([ww / 2, hh / 2]);
	} #endregion
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[| 2].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _axis = _data[1];
		var _amou = _data[2];
		var _wrap = _data[3];
		var _cent = _data[4];
		var _samp = struct_try_get(attributes, "oversample");
		
		surface_set_shader(_outSurf, sh_skew);
		shader_set_interpolation(_data[0]);
			shader_set_dim("dimension",	_data[0]);
			shader_set_f("center",		_cent);
			shader_set_i("axis",		_axis);
			shader_set_f_map("amount",  _amou, _data[12], inputs[| 2]);
			shader_set_i("sampleMode",	_samp);
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[6], _data[7]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[9]);
		
		return _outSurf;
	} #endregion
}