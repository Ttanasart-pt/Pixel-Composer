function Node_Interlaced(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Interlace";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 1;
	
	inputs[| 2] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 3] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 4] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(2); // inputs 5, 6
	
	inputs[| 7] = nodeValue("Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "X", "Y" ]);
	
	inputs[| 8] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 9] = nodeValue("Invert", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	temp_surface = [ ];
	
	input_display_list = [ 1, 
		["Surface", false], 0, 2, 3, 4, 
		["Effects", false], 7, 8, 9, 
	];
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
		
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _surf = _data[0];
		var _axis = _data[7];
		var _size = _data[8];
		var _invt = _data[9];
		
		var _dim  = surface_get_dimension(_surf);
		
		surface_set_shader(_outSurf, sh_interlaced);
			shader_set_i("useSurf", CURRENT_FRAME >= 1);
			shader_set_surface("prevFrame", array_safe_get(temp_surface, _array_index));
			shader_set_2("dimension", _dim);
			shader_set_i("axis",      _axis);
			shader_set_i("invert",    _invt);
			shader_set_f("size",      _size);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		temp_surface[_array_index] = surface_verify(array_safe_get(temp_surface, _array_index), _dim[0], _dim[1]);
		surface_set_shader(temp_surface[_array_index], noone);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[2], _data[3]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return _outSurf;
	} #endregion
}