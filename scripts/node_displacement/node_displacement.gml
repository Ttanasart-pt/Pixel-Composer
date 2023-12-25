function Node_Displace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Displace";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Displace map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [1, 0], "Vector to displace pixel by." )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 3] = nodeValue("Strength",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setMappable(15);
	
	inputs[| 4] = nodeValue("Mid value",  self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0., "Brightness value to be use as a basis for 'no displacement'.")
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue("Color data",  self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, @"Use color data set extra information.
    - Ignore: Don't use color data.
    - Vector: Use red as X displacement, green as Y displacement.
    - Angle: Use red as angle, green as distance.")
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Ignore", "Vector", "Angle" ]);
	
	inputs[| 6] = nodeValue("Iterate",  self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, @"If not set, then strength value is multiplied directly to the displacement.
If set, then strength value control how many times the effect applies on itself.");
	
	inputs[| 7] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
	
	inputs[| 8] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 9] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 10] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 10;
	
	inputs[| 11] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Overwrite", "Min", "Max" ]);
		
	inputs[| 12] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(8); // inputs 13, 14
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 15] = nodeValue("Strength map",   self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(false, false);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	input_display_list = [ 10, 12, 
		["Surfaces",	 true],	0, 8, 9, 13, 14, 
		["Displace",	false], 1, 3, 15, 4,
		["Color",		false], 5, 2, 
		["Algorithm",	 true],	6, 11, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[| 2].setVisible(getInputData(5) == 0);
		inputs[| 3].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var ww = surface_get_width_safe(_data[0]);
		var hh = surface_get_height_safe(_data[0]);
		var mw = surface_get_width_safe(_data[1]);
		var mh = surface_get_height_safe(_data[1]);
		
		surface_set_shader(_outSurf, sh_displace);
		shader_set_interpolation(_data[0]);
			shader_set_surface("map", _data[1]);
			shader_set_f("dimension",     [ww, hh]);
			shader_set_f("map_dimension", [mw, mh]);
			shader_set_f("displace",      _data[ 2]);
			shader_set_f_map("strength",  _data[ 3], _data[15], inputs[| 3]);
			shader_set_f("middle",        _data[ 4]);
			shader_set_i("use_rg",        _data[ 5]);
			shader_set_i("iterate",       _data[ 6]);
			shader_set_i("blendMode",     _data[11]);
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[8], _data[9]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[12]);
		
		return _outSurf;
	} #endregion
}