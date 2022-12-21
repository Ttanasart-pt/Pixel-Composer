function Node_Pixel_Cloud(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Pixel Cloud";
	
	shader = sh_pixel_cloud;
	uniform_sed = shader_get_uniform(shader, "seed");
	uniform_str = shader_get_uniform(shader, "strength");
	uniform_dis = shader_get_uniform(shader, "dist");
	
	uniform_map_use = shader_get_uniform(shader, "useMap");
	uniform_map = shader_get_sampler_index(shader, "strengthMap");
	
	uniform_grad_blend = shader_get_uniform(shader, "gradient_blend");
	uniform_grad = shader_get_uniform(shader, "gradient_color");
	uniform_grad_time = shader_get_uniform(shader, "gradient_time");
	uniform_grad_key = shader_get_uniform(shader, "gradient_keys");
	
	uniform_alpha = shader_get_uniform(shader, "alpha_curve");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom(100000));
		
	inputs[| 2] = nodeValue(2, "Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	inputs[| 3] = nodeValue(3, "Strength map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 4] = nodeValue(4, "Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setDisplay(VALUE_DISPLAY.gradient);
	
	inputs[| 5] = nodeValue(5, "Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 6] = nodeValue(6, "Alpha over lifetime", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, [1, 1, 1, 1])
		.setDisplay(VALUE_DISPLAY.curve);
	
	input_display_list = [
		["Input",		true],	0, 1,
		["Movement",   false],	5, 2, 3, 
		["Color",		true],	4, 6
	]
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _sed = _data[1];
		var _str = _data[2];
		var _map = _data[3];
		
		var _gra = _data[4];
		var _gra_data = inputs[| 4].getExtraData();
		var _grad_color = [];
		var _grad_time  = [];
		
		var _dis = _data[5];
		var _alp = _data[6];
		
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
			
			shader_set_uniform_i(uniform_grad_blend, ds_list_get(_gra_data, 0));
			shader_set_uniform_f_array(uniform_grad, _grad_color);
			shader_set_uniform_f_array(uniform_grad_time, _grad_time);
			shader_set_uniform_i(uniform_grad_key, ds_list_size(_gra));
			
			shader_set_uniform_f_array(uniform_alpha, _alp);
			
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}