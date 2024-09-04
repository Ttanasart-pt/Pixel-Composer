function Node_Flip(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Flip";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Enum_Button("Axis", self,  0, [ "x", "y" ]));
	
	newInput(2, nodeValue_Bool("Active", self, true));
		active_index = 2;
		
	input_display_list = [ 2, 
		["Surfaces", true],	0, 
		["Flip",	false],	1,
	]
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _axis = _data[1];
		
		surface_set_shader(_outSurf, sh_flip);
			shader_set_i("axis", _axis);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	}
}