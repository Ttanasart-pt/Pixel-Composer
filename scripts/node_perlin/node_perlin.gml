function Node_Perlin(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Perlin Noise";
	
	shader = sh_perlin_tiled;
	uniform_dim = shader_get_uniform(shader, "u_resolution");
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_sca = shader_get_uniform(shader, "scale");
	uniform_ite = shader_get_uniform(shader, "iteration");
	uniform_sed = shader_get_uniform(shader, "seed");
	uniform_til = shader_get_uniform(shader, "tile");
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 5, 5 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2);
	
	inputs[| 4] = nodeValue("Tile", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		
	inputs[| 5] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom(99999));
	
	input_display_list = [
		["Surface",		 true],	0, 5, 
		["Noise",		false],	1, 2, 3, 4, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		var _sca = _data[2];
		var _ite = _data[3];
		var _til = _data[4];
		var _sed = _data[5];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
		shader_set(shader);
			shader_set_uniform_f_array_safe(uniform_dim, _dim);
			shader_set_uniform_f_array_safe(uniform_pos, _pos);
			shader_set_uniform_f_array_safe(uniform_sca, _sca);
			shader_set_uniform_f(uniform_sed, _sed);
			shader_set_uniform_i(uniform_til, _til);
			shader_set_uniform_i(uniform_ite, _ite);
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
}