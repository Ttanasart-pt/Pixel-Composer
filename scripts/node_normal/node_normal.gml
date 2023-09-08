function Node_Normal(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Normal";
	
	uniform_dim = shader_get_uniform(sh_normal, "dimension");
	uniform_hei = shader_get_uniform(sh_normal, "height");
	uniform_smt = shader_get_uniform(sh_normal, "smooth");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 2] = nodeValue("Smooth", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Include diagonal pixel in normal calculation, which leads to smoother output.");
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 3;
		
	input_display_list = [ 3,
		["Output",	 false], 0,
		["Normal",	 false], 1, 2, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _hei = _data[1];
		var _smt = _data[2];
		
		surface_set_shader(_outSurf, sh_normal);
		shader_set_uniform_f(uniform_hei, _hei);
		shader_set_uniform_i(uniform_smt, _smt);
		shader_set_uniform_f_array_safe(uniform_dim, [ surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]) ]);
			
		draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		return _outSurf;
	}
}