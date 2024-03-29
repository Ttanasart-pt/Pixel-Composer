function Node_Tile_Random(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Tile Random";
	dimension_index = -1;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Randomness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 1, 
		["Surfaces", true], 0,
		["Tiling",	false], 2,
	];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var dim   = _data[1];
		var rand  = _data[2];
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		_outSurf = surface_verify(_outSurf, dim[0], dim[1]);
		
		surface_set_shader(_outSurf, sh_tile_random);
			shader_set_surface("surface", _surf);
			shader_set_f("blend", rand);
			shader_set_f("scale", dim[0] / _sw, dim[1] / _sh);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, dim[0], dim[1]);
		surface_reset_shader();
		
		return _outSurf;
	}
}