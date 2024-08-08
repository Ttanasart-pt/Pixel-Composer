function Node_Displace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Displace";
	
	inputs[0] = nodeValue_Surface("Surface in", self);
	
	inputs[1] = nodeValue_Surface("Displace map", self);
	
	inputs[2] = nodeValue_Vector("Position", self, [ 1, 0 ] )
		.setTooltip("Vector to displace pixel by.")
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[3] = nodeValue_Float("Strength",   self, 1)
		.setMappable(15);
	
	inputs[4] = nodeValue_Float("Mid value",  self, 0., "Brightness value to be use as a basis for 'no displacement'.")
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[5] = nodeValue_Enum_Button("Mode", self, 0, [ "Linear", "Vector", "Angle", "Gradient" ])
		.setTooltip(@"Use color data for extra information.
    - Linear: Displace along a single line (defined by the position value).
    - Vector: Use red as X displacement, green as Y displacement.
    - Angle: Use red as angle, green as distance.
    - Gradient: Displace down the brightness value defined by the Displace map.");
	
	inputs[6] = nodeValue_Bool("Iterate",  self, false, @"If not set, then strength value is multiplied directly to the displacement.
If set, then strength value control how many times the effect applies on itself.");
	
	inputs[7] = nodeValue_Enum_Scroll("Oversample mode", self,  0, [ "Empty", "Clamp", "Repeat" ])
		.setTooltip("How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.");
	
	inputs[8] = nodeValue_Surface("Mask", self);
	
	inputs[9] = nodeValue_Float("Mix", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[10] = nodeValue_Bool("Active", self, true);
		active_index = 10;
	
	inputs[11] = nodeValue_Enum_Scroll("Blend mode", self,  0, [ "Overwrite", "Min", "Max" ]);
		
	inputs[12] = nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(8); // inputs 13, 14
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[15] = nodeValue_Surface("Strength map",   self)
		.setVisible(false, false);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[16] = nodeValue_Bool("Separate axis", self, false);
	
	inputs[17] = nodeValue_Surface("Displace map 2", self);
	
	input_display_list = [ 10, 12, 
		["Surfaces",	  true], 0, 8, 9, 13, 14, 
		["Strength",	 false], 1, 17, 3, 15, 4,
		["Displacement", false], 5, 16, 2, 
		["Algorithm",	  true], 6, 11, 
	];
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static step = function() { #region
		__step_mask_modifier();
		inputs[3].mappableStep();
		
		var _mode = getInputData(5);
		var _sep  = getInputData(16);
		
		var _dsp2 = (_mode == 1 || _mode == 2) && _sep;
		
		inputs[ 2].setVisible(_mode == 0);
		inputs[16].setVisible(_mode == 1 || _mode == 2);
		inputs[17].setVisible(_dsp2, _dsp2);
		
		if(_mode == 1 && _sep) {
			inputs[ 1].setName("Displace X");
			inputs[17].setName("Displace Y");
			
		} else if(_mode == 2 && _sep) {
			inputs[ 1].setName("Displace angle");
			inputs[17].setName("Displace amount");
			
		} else {
			inputs[ 1].setName("Displace map");
		}
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var ww = surface_get_width_safe(_data[0]);
		var hh = surface_get_height_safe(_data[0]);
		var mw = surface_get_width_safe(_data[1]);
		var mh = surface_get_height_safe(_data[1]);
		
		surface_set_shader(_outSurf, sh_displace);
		shader_set_interpolation(_data[0]);
			shader_set_surface("map",  _data[1]);
			shader_set_surface("map2", _data[17]);
			
			shader_set_f("dimension",     [ww, hh]);
			shader_set_f("map_dimension", [mw, mh]);
			shader_set_f("displace",      _data[ 2]);
			shader_set_f_map("strength",  _data[ 3], _data[15], inputs[3]);
			shader_set_f("middle",        _data[ 4]);
			shader_set_i("mode",          _data[ 5]);
			shader_set_i("iterate",       _data[ 6]);
			shader_set_i("blendMode",     _data[11]);
			shader_set_i("sepAxis",       _data[16]);
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[8], _data[9]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[12]);
		
		return _outSurf;
	} #endregion
}