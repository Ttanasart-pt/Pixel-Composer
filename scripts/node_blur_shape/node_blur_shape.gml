function Node_Blur_Shape(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shape Blur";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	inputs[| 1] = nodeValue("Blur Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 2] = nodeValue("Blur mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 3] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 4] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	inputs[| 6] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	inputs[| 7] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Blur", "Max" ]);
	
	__init_mask_modifier(3); // inputs 7, 8
	
	inputs[| 9] = nodeValue("Gamma Correction", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	input_display_list = [ 5, 6, 
		["Surfaces", true],	0, 3, 4, 7, 8, 
		["Blur",	false],	7, 1, 2, 9, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
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