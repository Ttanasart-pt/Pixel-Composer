function Node_Pixel_Cloud(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Cloud";
	
	shader = sh_pixel_cloud;
	uniform_sed = shader_get_uniform(shader, "seed");
	uniform_str = shader_get_uniform(shader, "strength");
	uniform_dis = shader_get_uniform(shader, "dist");
	
	uniform_map_use = shader_get_uniform(shader, "useMap");
	uniform_map		= shader_get_sampler_index(shader, "strengthMap");
	
	uniform_grad_blend	= shader_get_uniform(shader, "gradient_blend");
	uniform_grad		= shader_get_uniform(shader, "gradient_color");
	uniform_grad_time	= shader_get_uniform(shader, "gradient_time");
	uniform_grad_key	= shader_get_uniform(shader, "gradient_keys");
	
	uniform_alpha = shader_get_uniform(shader, "alpha_curve");
	uniform_alamo = shader_get_uniform(shader, "curve_amount");
	uniform_rnd   = shader_get_uniform(shader, "randomAmount");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom(100000));
		
	inputs[| 2] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 2, 0.01]);
	
	inputs[| 3] = nodeValue("Strength map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 4] = nodeValue("Color over lifetime", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) );
	
	inputs[| 5] = nodeValue("Distance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 6] = nodeValue("Alpha over lifetime", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_11);
	
	inputs[| 7] = nodeValue("Random blending", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	inputs[| 8] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 8;
		
	input_display_list = [ 8, 
		["Input",		true],	0, 1,
		["Movement",   false],	5, 2, 3, 
		["Color",		true],	4, 6, 7
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _sed = _data[1];
		var _str = _data[2];
		var _map = _data[3];		
		var _gra = _data[4];		
		var _dis = _data[5];
		var _alp = _data[6];
		var _rnd = _data[7];
		
		var _grad = _gra.toArray();
		var _grad_color = _grad[0];
		var _grad_time	= _grad[1];
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		shader_set(shader);
			shader_set_uniform_f(uniform_sed, _sed);
			shader_set_uniform_f(uniform_str, _str);
			shader_set_uniform_f(uniform_dis, _dis);
			if(is_surface(_map)) {
				shader_set_uniform_i(uniform_map_use, 1);
				texture_set_stage(uniform_map, surface_get_texture(_map));
			} else {
				shader_set_uniform_i(uniform_map_use, 0);
			}
			
			shader_set_uniform_i(uniform_grad_blend, _gra.type);
			shader_set_uniform_f_array_safe(uniform_grad, _grad_color);
			shader_set_uniform_f_array_safe(uniform_grad_time, _grad_time);
			shader_set_uniform_i(uniform_grad_key, array_length(_gra.keys));
			
			shader_set_uniform_f_array_safe(uniform_alpha, _alp);
			shader_set_uniform_i(uniform_alamo, array_length(_alp));
			shader_set_uniform_f(uniform_rnd, _rnd);
			
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}