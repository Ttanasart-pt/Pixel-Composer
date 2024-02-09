function Node_Kuwahara(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Kuwahara";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 1;
	
	inputs[| 2] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 1, 0, 2 ];
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		
		surface_set_shader(_outSurf, sh_kuwahara);
			shader_set_f("dimension", surface_get_dimension(_data[0]));
			shader_set_i("radius",    _data[2]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}