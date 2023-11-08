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
	
	inputs[| 1] = nodeValue("Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject([ c_black, c_white ]) );
		
	inputs[| 2] = nodeValue("Gradient shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, .01 ] });
	
	inputs[| 3] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 4] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	inputs[| 6] = nodeValue("Multiply alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	input_display_list = [ 5, 
		["Surfaces",	 true], 0, 3, 4, 
		["Colorize",	false], 1, 2, 6, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _gra		= _data[1];
		var _gra_shift	= _data[2];
		var _alpha		= _data[6];
		
		var _grad = _gra.toArray();
		var _grad_color = _grad[0];
		var _grad_time	= _grad[1];
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE;
			
			shader_set(shader);
			shader_set_uniform_i(uniform_grad_blend, _gra.type);
			shader_set_uniform_f_array_safe(uniform_color, _grad_color);
			shader_set_uniform_f_array_safe(uniform_time,  _grad_time);
			shader_set_uniform_f(uniform_shift,  _gra_shift);
			shader_set_uniform_i(uniform_key, array_length(_gra.keys));
			shader_set_uniform_i(uniform_alpha, _alpha);
			
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL;
		surface_reset_target(); 
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		
		return _outSurf;
	} #endregion
}