function Node_Alpha_Grey(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Alpha to Grey";
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_OVERRIDE
		shader_set(sh_alpha_grey);
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}