function Node_Colorize(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Colorize";
	
	uniform_grad_blend = shader_get_uniform(sh_colorize, "gradient_blend");
	uniform_color = shader_get_uniform(sh_colorize, "gradient_color");
	uniform_time = shader_get_uniform(sh_colorize, "gradient_time");
	uniform_shift = shader_get_uniform(sh_colorize, "gradient_shift");
	uniform_key = shader_get_uniform(sh_colorize, "keys");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setDisplay(VALUE_DISPLAY.gradient);
		
	inputs[| 2] = nodeValue(2, "Gradient shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ -1, 1, .01 ]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _gra = _data[1];
		var _gra_data = inputs[| 1].getExtraData();
		var _gra_shift = _data[2];
		
		var _grad_color = [];
		var _grad_time  = [];
		
		for(var i = 0; i < ds_list_size(_gra); i++) {
			_grad_color[i * 4 + 0] = color_get_red(_gra[| i].value) / 255;
			_grad_color[i * 4 + 1] = color_get_green(_gra[| i].value) / 255;
			_grad_color[i * 4 + 2] = color_get_blue(_gra[| i].value) / 255;
			_grad_color[i * 4 + 3] = 1;
			_grad_time[i]  = _gra[| i].time;
		}
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD
			
			shader_set(sh_colorize);
			shader_set_uniform_i(uniform_grad_blend, ds_list_get(_gra_data, 0));
			shader_set_uniform_f_array(uniform_color, _grad_color);
			shader_set_uniform_f_array(uniform_time,  _grad_time);
			shader_set_uniform_f(uniform_shift,  _gra_shift);
			shader_set_uniform_i(uniform_key, ds_list_size(_gra));
			
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL
		surface_reset_target(); 
		
		return _outSurf;
	}
}