function Node_JPEG(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "JPEG";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 1;
		
	inputs[| 2] = nodeValue("Patch Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8);
	
	inputs[| 3] = nodeValue("Compression", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 10);
	
	inputs[| 4] = nodeValue("Reconstruction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8);
	
	inputs[| 5] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 6] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(5); // inputs 8, 9
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 1, 
		["Surface", false], 0, 5, 6, 7, 
		["Effects", false], 2, 3, 4, 
	];
	
	temp_surface = array_create(2);
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _surf = _data[0];
		var _patc = _data[2];
		var _comp = _data[3];
		var _recn = _data[4];
		
		var _dim  = surface_get_dimension(_surf);
		
		for( var i = 0; i < 2; i++ ) temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1], surface_rgba16float);
			
		surface_set_shader(temp_surface[0], sh_jpeg_dct);
			shader_set_f("dimension",   _dim);
			shader_set_i("patch",       _patc);
			shader_set_f("compression", _comp);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		surface_set_shader(temp_surface[1], sh_jpeg_recons);
			shader_set_f("dimension",   _dim);
			shader_set_i("patch",       _patc);
			shader_set_i("reconstruct", _recn);
			
			draw_surface_safe(temp_surface[0]);
		surface_reset_shader();
		
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[1]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[7]);
		
		return _outSurf;
	} #endregion
}