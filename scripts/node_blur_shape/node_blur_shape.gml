function Node_Blur_Shape(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shape Blur";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	newInput(1, nodeValue_Surface("Blur Shape", self));
	
	newInput(2, nodeValue_Surface("Blur mask", self));
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	newInput(7, nodeValue_Enum_Button("Mode", self,  0, [ "Blur", "Max" ]));
	
	__init_mask_modifier(3); // inputs 8, 9, 
	
	newInput(10, nodeValue_Bool("Gamma Correction", self, false));
	
	input_display_list = [ 5, 6, 
		["Surfaces", true],	0, 3, 4, 8, 9, 
		["Blur",	false],	7, 1, 2, 10, 
	];
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_oversample();
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region	
		if(!is_surface(_data[0])) return _outSurf;
		
		var _samp = struct_try_get(attributes, "oversample");
		var _blur = _data[1];
		var _mask = _data[2];
		var _mode = _data[7];
		var _gam  = _data[9];
		
		surface_set_shader(_outSurf, sh_blur_shape);
			shader_set_f("dimension",         surface_get_dimension(_data[0]));
			shader_set_f("blurMaskDimension", surface_get_dimension(_blur));
			var b = shader_set_surface("blurMask",    _blur);
			shader_set_i("sampleMode", _samp);
			shader_set_i("mode",       _mode);
			shader_set_i("mode",       _mode);
			shader_set_i("gamma",      _gam);
			
			gpu_set_tex_filter_ext(b, true);
			
			shader_set_i("useMask",    is_surface(_mask));
			shader_set_surface("mask", _mask);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	} #endregion
}