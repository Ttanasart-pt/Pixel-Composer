function Node_Colorize(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Colorize";
	
	shader = sh_colorize;
	uniform_grad_blend = shader_get_uniform(shader, "gradient_blend");
	uniform_color	= shader_get_uniform(shader, "gradient_color");
	uniform_time	= shader_get_uniform(shader, "gradient_time");
	uniform_shift	= shader_get_uniform(shader, "gradient_shift");
	uniform_key		= shader_get_uniform(shader, "gradient_keys");
	uniform_alpha	= shader_get_uniform(shader, "multiply_alpha");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [ new gradientKey(0, c_black), new gradientKey(1, c_white) ] )
		.setDisplay(VALUE_DISPLAY.gradient);
		
	inputs[| 2] = nodeValue("Gradient shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ -1, 1, .01 ]);
	
	inputs[| 3] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 4] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	inputs[| 6] = nodeValue("Multiply alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	input_display_list = [ 5, 
		["Surface",		 true], 0, 3, 4, 
		["Colorize",	false], 1, 2, 6, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _gra		= _data[1];
		var _gra_data	= inputs[| 1].getExtraData();
		var _gra_shift	= _data[2];
		var _alpha		= _data[6];
		
		var _grad = gradient_to_array(_gra);
		var _grad_color = _grad[0];
		var _grad_time	= _grad[1];
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE;
			
			shader_set(shader);
			shader_set_uniform_i(uniform_grad_blend, ds_list_get(_gra_data, 0));
			shader_set_uniform_f_array_safe(uniform_color, _grad_color);
			shader_set_uniform_f_array_safe(uniform_time,  _grad_time);
			shader_set_uniform_f(uniform_shift,  _gra_shift);
			shader_set_uniform_i(uniform_key, array_length(_gra));
			shader_set_uniform_i(uniform_alpha, _alpha);
			
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL;
		surface_reset_target(); 
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		
		return _outSurf;
	}
}