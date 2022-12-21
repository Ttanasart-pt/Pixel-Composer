function Node_Color_adjust(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Color adjust";
	
	shader = sh_color_adjust;
	uniform_bri = shader_get_uniform(shader, "brightness");
	uniform_exp = shader_get_uniform(shader, "exposure");
	uniform_con = shader_get_uniform(shader, "contrast");
	uniform_hue = shader_get_uniform(shader, "hue");
	uniform_sat = shader_get_uniform(shader, "sat");
	uniform_val = shader_get_uniform(shader, "val");
	uniform_alp = shader_get_uniform(shader, "alpha");
	
	uniform_bl  = shader_get_uniform(shader, "blend");
	uniform_bla = shader_get_uniform(shader, "blendAlpha");
	
	uniform_mask_use	= shader_get_uniform(shader, "use_mask");
	uniform_mask		= shader_get_sampler_index(shader, "mask");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Brightness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ -1, 1, 0.01]);
	
	inputs[| 2] = nodeValue(2, "Contrast",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [  0, 1, 0.01]);
	
	inputs[| 3] = nodeValue(3, "Hue",        self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ -1, 1, 0.01]);
	
	inputs[| 4] = nodeValue(4, "Saturation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ -1, 1, 0.01]);
	
	inputs[| 5] = nodeValue(5, "Value",      self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ -1, 1, 0.01]);
	
	inputs[| 6] = nodeValue(6, "Blend",   self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 7] = nodeValue(7, "Blend alpha",  self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	inputs[| 8] = nodeValue(8, "Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 9] = nodeValue(9, "Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	inputs[| 10] = nodeValue(10, "Exposure", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 4, 0.01]);
		
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [0, 8, 
		["Brightness",	false], 1, 10, 2, 
		["HSV",			false], 3, 4, 5, 
		["Color blend", false], 6, 7, 9
	];
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _bri = _data[1];
		var _con = _data[2];
		var _hue = _data[3];
		var _sat = _data[4];
		var _val = _data[5];
		
		var _bl  = _data[6];
		var _bla = _data[7];
		var _m   = _data[8];
		var _alp = _data[9];
		var _exp = _data[10];
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
		
		shader_set(shader);
			shader_set_uniform_i(uniform_mask_use, _m != DEF_SURFACE);
			texture_set_stage(uniform_mask, surface_get_texture(_m));
			
			shader_set_uniform_f(uniform_bri, _bri);
			shader_set_uniform_f(uniform_exp, _exp);
			shader_set_uniform_f(uniform_con, _con);
			shader_set_uniform_f(uniform_hue, _hue);
			shader_set_uniform_f(uniform_sat, _sat);
			shader_set_uniform_f(uniform_val, _val);
			
			shader_set_uniform_f_array(uniform_bl, [color_get_red(_bl) / 255, color_get_green(_bl) / 255, color_get_blue(_bl) / 255, 1.0]);
			shader_set_uniform_f(uniform_bla, _bla);
			
			gpu_set_colorwriteenable(1, 1, 1, 0);
			if(is_surface(_data[0])) draw_surface_safe(_data[0], 0, 0);
			gpu_set_colorwriteenable(1, 1, 1, 1);
			if(is_surface(_data[0])) draw_surface_ext_safe(_data[0], 0, 0, 1, 1, 0, c_white, _alp);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}