function Node_Polar(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Polar";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 2] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 3;
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 3,
		["Surface",	 false], 0, 1, 2, 
	]
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		surface_set_shader(_outSurf, sh_polar);
		shader_set_interpolation(_data[0]);
		draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		
		return _outSurf;
	}
}