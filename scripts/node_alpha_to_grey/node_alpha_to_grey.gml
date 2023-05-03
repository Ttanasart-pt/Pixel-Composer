function Node_Alpha_Grey(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Alpha to Grey";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 1;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 1, 
		["Output",	 false], 0, 
	]
	
	attribute_surface_depth();
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		shader_set(sh_alpha_grey);
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}