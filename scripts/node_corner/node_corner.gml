function Node_Corner(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Round corner";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2)
		.setDisplay(VALUE_DISPLAY.slider, { range: [2, 16, 0.1] });
	
	inputs[| 2] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 3] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 4] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 4;
	
	inputs[| 5] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(2); // inputs 6, 7
	
	input_display_list = [ 4, 5, 
		["Surfaces", true], 0, 2, 3, 6, 7, 
		["Corner",	false], 1,
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var wd = _data[1];
		
		var temp = surface_create_valid(surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]), attrDepth());
		
		surface_set_shader(temp, sh_corner_erode);
			shader_set_f("dimension", [surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0])]);
			shader_set_f("size",      wd);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		surface_set_shader(_outSurf, sh_corner);
			shader_set_f("dimension", [surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0])]);
			shader_set_f("rad",       wd);
			shader_set_surface("original", _data[0]);
			
			draw_surface_safe(temp);
		surface_reset_shader();
		
		surface_free(temp);
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[2], _data[3]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[5]);
		
		return _outSurf;
	}
}