function Node_Offset(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Offset";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newInput(1, nodeValue_Float("X Offset", 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(2, nodeValue_Float("Y Offset", 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Bool("Active", true));
		active_index = 3;
		
	input_display_list = [ 3, 
		["Surfaces", true],	0, 
		["Offset",	false],	1, 2, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		
		surface_set_shader(_outSurf, sh_offset);
			shader_set_f("offset", _data[1], _data[2]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	}
}