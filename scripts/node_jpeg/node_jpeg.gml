function Node_JPEG(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "JPEG";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
		active_index = 1;
		
	newInput(2, nodeValue_Int("Patch Size", self, 8))
		.setValidator(VV_min(1));
	
	newInput(3, nodeValue_Float("Compression", self, 10));
	
	newInput(4, nodeValue_Int("Reconstruction", self, 8))
		.setValidator(VV_min(0));
	
	newInput(5, nodeValue_Surface("Mask", self));
	
	newInput(6, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(7, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(5); // inputs 8, 9
	
	newInput(10, nodeValue_Enum_Scroll("Transformation", self,  0, [ "Cosine", "Zigzag", "Smooth Zigzag", "Step" ]));
	
	newInput(11, nodeValue_Rotation("Phase", self, 0));
	
	newInput(12, nodeValue_Bool("Deconstruct Only", self, false))
	
	newInput(13, nodeValue_Bool("Reconstruct All", self, false))
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		["Surface", false], 0, 5, 6, 7, 
		["Effects", false], 2, 3, 13, 4, 10, 11, 12, 
	];
	
	temp_surface = array_create(2);
	
	attribute_surface_depth();
	
	static step = function() {
		var _reall = getSingleValue(13);
		inputs[4].setVisible(!_reall);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
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
	}
}