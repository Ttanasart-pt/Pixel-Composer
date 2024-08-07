function Node_Offset(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Offset";
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue_Float("X Offset", self, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 2] = nodeValue_Float("Y Offset", self, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue_Bool("Active", self, true);
		active_index = 3;
		
	input_display_list = [ 3, 
		["Surfaces", true],	0, 
		["Offset",	false],	1, 2, 
	]
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		surface_set_shader(_outSurf, sh_offset);
			shader_set_f("offset", _data[1], _data[2]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	}
}