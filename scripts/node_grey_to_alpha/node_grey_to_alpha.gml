function Node_Grey_Alpha(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Grey to alpha";
	
	shader = sh_grey_alpha;
	uniform_rep	= shader_get_uniform(shader, "replace");
	uniform_col	= shader_get_uniform(shader, "color");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Replace color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	inputs[| 2] = nodeValue(2, "Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static step = function() {
		var _replace	= inputs[| 1].getValue();	
		inputs[| 2].setVisible(_replace);
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _replace	= inputs[| 1].getValue();
		var _color		= inputs[| 2].getValue();
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVER
		
		shader_set(shader);
			shader_set_uniform_i(uniform_rep, _replace);
			shader_set_uniform_f_array(uniform_col, colToVec4(_color));
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}