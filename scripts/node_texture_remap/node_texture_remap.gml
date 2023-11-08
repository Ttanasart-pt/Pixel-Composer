function Node_Texture_Remap(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Texture Remap";
	
	shader = sh_texture_remap;
	uniform_map = shader_get_sampler_index(shader, "map");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("RG Map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0, "Displacement map where red retermine the X position, and green determine the Y position.");
	
	inputs[| 2] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 2;
	
	inputs[| 3] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Surface", "RG Map" ]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 2,
		["Surfaces",	 false], 0, 1, 3, 
	]
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static processData_prebatch  = function() { shader_preset_interpolation(shader);  }
	static processData_postbatch = function() { shader_postset_interpolation(); }
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		if(!is_surface(_data[1])) return _outSurf;
		
		var _dim = _data[3];
		var _sw = surface_get_width(_data[_dim]);
		var _sh = surface_get_height(_data[_dim]);
		
		_outSurf = surface_verify(_outSurf, _sw, _sh);
		
		surface_set_shader(_outSurf, shader);
		shader_set_interpolation_surface(_data[0]);
			texture_set_stage(uniform_map, surface_get_texture(_data[1]));
			draw_surface_stretched_safe(_data[0], 0, 0, _sw, _sh);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}