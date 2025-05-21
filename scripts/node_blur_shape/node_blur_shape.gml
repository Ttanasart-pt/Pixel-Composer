function Node_Blur_Shape(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shape Blur";
	
	newInput(0, nodeValue_Surface("Surface In"));
	newInput(1, nodeValue_Surface("Blur Shape"));
	
	newInput(2, nodeValue_Surface("Blur mask"));
	
	newInput(3, nodeValue_Surface("Mask"));
	
	newInput(4, nodeValue_Float("Mix", 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", true));
		active_index = 5;
	
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	newInput(7, nodeValue_Enum_Button("Mode",  0, [ "Blur", "Max" ]));
	
	__init_mask_modifier(3); // inputs 8, 9, 
	
	newInput(10, nodeValue_Bool("Gamma Correction", false));
	
	input_display_list = [ 5, 6, 
		["Surfaces", true],	0, 3, 4, 8, 9, 
		["Blur",	false],	7, 1, 2, 10, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	attribute_oversample();
	
	static processData = function(_outSurf, _data, _array_index) {	
		if(!is_surface(_data[0])) return _outSurf;
		
		var _samp = getAttribute("oversample");
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
	}
}