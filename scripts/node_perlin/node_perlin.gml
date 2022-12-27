function Node_Perlin(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Perlin";
	
	shader = sh_perlin_tiled;
	uniform_dim = shader_get_uniform(shader, "u_resolution");
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_sca = shader_get_uniform(shader, "scale");
	uniform_ite = shader_get_uniform(shader, "iteration");
	uniform_bri = shader_get_uniform(shader, "bright");
	uniform_sed = shader_get_uniform(shader, "seed");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue(2, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 5, 5 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2);
	
	inputs[| 4] = nodeValue(4, "Brightness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
		
	inputs[| 5] = nodeValue(5, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2);
	
	input_display_list = [
		["Surface",		false],	0, 5, 
		["Noise",		false],	1, 2, 3, 4
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		var _sca = _data[2];
		var _ite = _data[3];
		var _bri = _data[4];
		var _sed = _data[5];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
		shader_set(shader);
			shader_set_uniform_f_array(uniform_dim, _dim);
			shader_set_uniform_f_array(uniform_pos, _pos);
			shader_set_uniform_f_array(uniform_sca, _sca);
			shader_set_uniform_f(uniform_bri, _bri);
			shader_set_uniform_f(uniform_sed, _sed);
			shader_set_uniform_i(uniform_ite, _ite);
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
	doUpdate();
}