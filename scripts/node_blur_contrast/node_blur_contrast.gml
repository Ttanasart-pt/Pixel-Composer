function Node_Blur_Contrast(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Contrast Blur";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 32, 0.1] });
	
	inputs[| 2] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2, "Brightness different to be blur together.")
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 4] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	inputs[| 6] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
		
	__init_mask_modifier(3); // inputs 7, 8
	
	inputs[| 9] = nodeValue("Gamma Correction", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	input_display_list = [ 5, 6, 
		["Surfaces", true], 0, 3, 4, 7, 8, 
		["Blur",	false], 1, 2, 9, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	temp_surface = [ surface_create(1, 1) ];
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _surf = _data[0];
		var _size = _data[1];
		var _tres = _data[2];
		var _mask = _data[3];
		var _mix  = _data[4];
		var _gam  = _data[9];
		
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		
		surface_set_shader(_outSurf, sh_blur_box_contrast);
			shader_set_f("dimension", [ ww, hh ]);
			shader_set_f("size",      _size);
			shader_set_f("treshold",  _tres);
			shader_set_i("gamma",     _gam);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	} #endregion
}