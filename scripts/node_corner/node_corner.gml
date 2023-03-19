function Node_Corner(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Round corner";
	
	uniform_er_dim   = shader_get_uniform(sh_corner_erode, "dimension");
	uniform_er_size  = shader_get_uniform(sh_corner_erode, "size");
	
	uniform_dim  = shader_get_uniform(sh_corner, "dimension");
	uniform_rad  = shader_get_uniform(sh_corner, "rad");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2)
		.setDisplay(VALUE_DISPLAY.slider, [2, 16, 1]);
	
	inputs[| 2] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 3] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 4] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 4;
	
	input_display_list = [ 4, 
		["Surface",	 true], 0, 2, 3, 
		["Corner",	false], 1,
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var wd = _data[1];
		
		var temp = surface_create_valid(surface_get_width(_data[0]), surface_get_height(_data[0]), attrDepth());
		
		surface_set_target(temp);
			DRAW_CLEAR
			BLEND_OVERRIDE;
			
			shader_set(sh_corner_erode);
			shader_set_uniform_f_array_safe(uniform_er_dim, [surface_get_width(_data[0]), surface_get_height(_data[0])]);
			shader_set_uniform_f(uniform_er_size, wd);
			draw_surface_safe(_data[0], 0, 0);
			
			BLEND_NORMAL;
			shader_reset();
		surface_reset_target();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE;
			
			shader_set(sh_corner);
			shader_set_uniform_f_array_safe(uniform_dim, [surface_get_width(_data[0]), surface_get_height(_data[0])]);
			shader_set_uniform_f(uniform_rad, wd);
			shader_set_surface(sh_corner, "original", _data[0]);
			draw_surface_safe(temp, 0, 0);
			
			BLEND_NORMAL;
		shader_reset();
		surface_reset_target();
		surface_free(temp);
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[2], _data[3]);
		
		return _outSurf;
	}
}