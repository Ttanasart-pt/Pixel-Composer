function Node_Glow(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Glow";
	
	shader = sh_outline_only;
	uniform_dim  = shader_get_uniform(shader, "dimension");
	uniform_size = shader_get_uniform(shader, "borderSize");
	uniform_colr = shader_get_uniform(shader, "borderColor");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Border", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 4, 1]);
	
	inputs[| 2] = nodeValue(2, "Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, [1, 16, 1]);
	
	inputs[| 3] = nodeValue(3, "Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, .25)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 2, 0.01]);
	
	inputs[| 4] = nodeValue(4, "Color",   self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _border = _data[1];
		var _size = _data[2];
		var _stre = _data[3];
		var cl    = _data[4];
		var pass1 = surface_create_valid(surface_get_width(_outSurf), surface_get_height(_outSurf));	
		
		surface_set_target(pass1);
		draw_clear_alpha(c_black, 1);
			shader_set(shader);
				shader_set_uniform_f_array(uniform_dim,  [ surface_get_width(_outSurf), surface_get_height(_outSurf) ]);
				shader_set_uniform_f(uniform_size, _size + _border);
				shader_set_uniform_f_array(uniform_colr, [1.0, 1.0, 1.0, 1.0]);
				
				if(is_surface(_data[0])) draw_surface_safe(_data[0], 0, 0);
			shader_reset();
		surface_reset_target();
		
		pass1 = surface_apply_gaussian(pass1, _size, false, c_black, 1);
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
		
			shader_set(sh_remove_black);
			if(is_surface(pass1)) draw_surface_ext_safe(pass1, 0, 0, 1, 1, 0, cl, _stre);
			shader_reset();
			
			if(is_surface(_data[0])) draw_surface_safe(_data[0], 0, 0);
		
		BLEND_NORMAL
		surface_reset_target();
		
		surface_free(pass1);
		
		return _outSurf;
	}
}