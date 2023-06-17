function Node_FXAA(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "FXAA";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	active_index = 1;
	
	input_display_list = [ 
		1, 0,
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {		
		surface_set_shader(_outSurf, sh_FXAA);
		gpu_set_tex_filter(true);
			shader_set_f("dimension", surface_get_width(_data[0]), surface_get_height(_data[0]));
			draw_surface_safe(_data[0], 0, 0);
		gpu_set_tex_filter(false);
		surface_reset_shader();
		
		return _outSurf;
	}
}