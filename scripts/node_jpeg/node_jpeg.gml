function Node_JPEG(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "JPEG";
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 1;
		
	inputs[| 2] = nodeValue("Patch Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8)
		.setValidator(VV_min(1));
	
	inputs[| 3] = nodeValue("Compression", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 10);
	
	inputs[| 4] = nodeValue("Reconstruction", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8)
		.setValidator(VV_min(0));
	
	inputs[| 5] = nodeValue_Surface("Mask", self);
	
	inputs[| 6] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(5); // inputs 8, 9
	
	inputs[| 10] = nodeValue_Enum_Scroll("Transformation", self,  0, [ "Cosine", "Zigzag", "Smooth Zigzag", "Step" ]);
	
	inputs[| 11] = nodeValue_Rotation("Phase", self, 0);
	
	inputs[| 12] = nodeValue("Deconstruct Only", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	inputs[| 13] = nodeValue("Reconstruct All", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 1, 
		["Surface", false], 0, 5, 6, 7, 
		["Effects", false], 2, 3, 13, 4, 10, 11, 12, 
	];
	
	temp_surface = array_create(2);
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
		
		var _reall = getSingleValue(13);
		
		inputs[| 4].setVisible(!_reall);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _surf  = _data[0];
		var _patc  = _data[2];
		var _comp  = _data[3];
		var _recn  = _data[4];
		var _tran  = _data[10];
		var _phas  = _data[11];
		var _recon = _data[12];
		var _reall = _data[13];
		
		var _dim  = surface_get_dimension(_surf);
		
		for( var i = 0; i < 2; i++ ) temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1], surface_rgba16float);
		
		if(!_recon) {
			surface_set_shader(temp_surface[0], sh_jpeg_dct);
				shader_set_f("dimension",   _dim);
				shader_set_i("patch",       _patc);
				shader_set_f("compression", _comp);
				shader_set_f("phase",       degtorad(_phas));
				shader_set_i("transform",   _tran);
				
				draw_surface_safe(_surf);
			surface_reset_shader();
		}
		
		surface_set_shader(temp_surface[1], sh_jpeg_recons);
			shader_set_f("dimension",   _dim);
			shader_set_i("patch",       _patc);
			shader_set_i("reconstruct", _reall? _patc : _recn);
			shader_set_f("phase",       degtorad(_phas));
			shader_set_i("transform",   _tran);
			
			draw_surface_safe(_recon? _surf : temp_surface[0]);
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