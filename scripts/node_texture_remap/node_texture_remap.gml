function Node_Texture_Remap(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Texture Remap";
	
	shader = sh_texture_remap;
	uniform_map = shader_get_sampler_index(shader, "map");
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Surface("RG Map", self, "Displacement map where red retermine the X position, and green determine the Y position."));
	
	newInput(2, nodeValue_Bool("Active", self, true));
		active_index = 2;
	
	newInput(3, nodeValue_Enum_Button("Dimension Source", self,  0, [ "Surface", "RG Map" ]));
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
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
		shader_set_interpolation(_data[0]);
			texture_set_stage(uniform_map, surface_get_texture(_data[1]));
			draw_surface_stretched_safe(_data[0], 0, 0, _sw, _sh);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}