function Node_Blur_Simple(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Simple blur";
	
	shader = sh_blur_simple;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_siz = shader_get_uniform(shader, "size");
	uniform_sam = shader_get_uniform(shader, "sampleMode");
	
	uniform_umk = shader_get_uniform(shader, "useMask");
	uniform_msk = shader_get_sampler_index(shader, "mask");
	uniform_ovr = shader_get_uniform(shader, "overrideColor");
	uniform_ovc = shader_get_uniform(shader, "overColor");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[| 2] = nodeValue("Oversample mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Empty", "Clamp", "Repeat" ]);
	
	inputs[| 3] = nodeValue("Blur mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 4] = nodeValue("Override color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Replace all color while keeping the alpha. Used to\nfix grey outline when bluring transparent pixel.");
	
	inputs[| 5] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 6] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 7] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 8] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 8;
	
	input_display_list = [ 8, 
		["Output", 	 true],	0, 6, 7, 
		["Blur",	false],	1, 3, 4, 5, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	attribute_oversample();
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {		
		if(!is_surface(_data[0])) return _outSurf;
		var _size	= _data[1];
		var _samp	= ds_map_try_get(attributes, "oversample");
		var _mask	= _data[3];
		var _isovr  = _data[4];
		var _overc  = _data[5];
		var _msk    = _data[6];
		var _mix    = _data[7];
		
		inputs[| 5].setVisible(_isovr);
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE;
			
			shader_set(shader);
			shader_set_uniform_f(uniform_dim, surface_get_width(_data[0]), surface_get_height(_data[0]));
			shader_set_uniform_f(uniform_siz, _size);
			shader_set_uniform_i(uniform_sam, _samp);
			
			shader_set_uniform_i(uniform_ovr, _isovr);
			shader_set_uniform_f_array_safe(uniform_ovc, colToVec4(_overc));
		
			shader_set_uniform_i(uniform_umk, is_surface(_mask));
			if(is_surface(_mask)) 
				texture_set_stage(uniform_msk, surface_get_texture(_mask));
			
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL;
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _msk, _mix);
		
		return _outSurf;
	}
}