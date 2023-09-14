function Node_Blur_Contrast(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Contrast Blur";
	
	shader = sh_blur_box_contrast;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_siz = shader_get_uniform(shader, "size");
	uniform_tes = shader_get_uniform(shader, "treshold");
	uniform_dir = shader_get_uniform(shader, "direction");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, [1, 32, 1]);
	
	inputs[| 2] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2, "Brightness different to be blur together.")
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 3] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 4] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	input_display_list = [ 5, 
		["Output",	 true], 0, 3, 4, 
		["Blur",	false], 1, 2,
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	temp_surface = [ surface_create(1, 1) ];
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _surf = _data[0];
		var _size = _data[1];
		var _tres = _data[2];
		var _mask = _data[3];
		var _mix  = _data[4];
		
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		
		temp_surface[0] = surface_verify(temp_surface[0], ww, hh, attrDepth());
		
		surface_set_target(temp_surface[0]);
		DRAW_CLEAR
		BLEND_OVERRIDE;
			shader_set(shader);
			shader_set_uniform_f_array_safe(uniform_dim, [ ww, hh ]);
			shader_set_uniform_f(uniform_siz, _size);
			shader_set_uniform_f(uniform_tes, _tres);
			shader_set_uniform_i(uniform_dir, 0);
			draw_surface_safe(_surf, 0, 0);
			shader_reset();
		BLEND_NORMAL;
		surface_reset_target();
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
			shader_set(shader);
			shader_set_uniform_i(uniform_dir, 1);
			draw_surface_safe(temp_surface[0], 0, 0);
			shader_reset();
		BLEND_NORMAL;
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _mask, _mix);
		
		return _outSurf;
	} #endregion
}