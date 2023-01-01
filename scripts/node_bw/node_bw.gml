function Node_BW(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "BW";
	
	shader = sh_bw;
	uniform_exp = shader_get_uniform(shader, "brightness");
	uniform_con = shader_get_uniform(shader, "contrast");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Brightness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ -1, 1, 0.01]);
	
	inputs[| 2] = nodeValue(2, "Contrast",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [ -1, 4, 0.01]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _exp = _data[1];
		var _con = _data[2];
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVER
		
		shader_set(shader);
			shader_set_uniform_f(uniform_exp, _exp);
			shader_set_uniform_f(uniform_con, _con);
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}