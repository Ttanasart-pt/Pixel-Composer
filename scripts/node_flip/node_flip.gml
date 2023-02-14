function Node_Flip(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Flip";
	
	shader = sh_flip;
	uniform_axs = shader_get_uniform(shader, "axis");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, ["x", "y"]);
	
	inputs[| 2] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 2;
		
	input_display_list = [ 2, 
		["Surface",	 true],	0, 
		["Flip",	false],	1,
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _axis = _data[1];
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_OVERRIDE;
			
			shader_set(shader);
			shader_set_uniform_i(uniform_axs, _axis);
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
						
			BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}