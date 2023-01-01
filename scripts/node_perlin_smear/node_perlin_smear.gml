function Node_Perlin_Smear(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Smear noise";
	
	shader = sh_perlin_smear;
	uniform_dim = shader_get_uniform(shader, "u_resolution");
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_sca = shader_get_uniform(shader, "scale");
	uniform_ite = shader_get_uniform(shader, "iteration");
	uniform_bri = shader_get_uniform(shader, "bright");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue(2, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 6])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 3);
	
	inputs[| 4] = nodeValue(4, "Brightness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		var _sca = _data[2];
		var _ite = _data[3];
		var _bri = _data[4];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
		shader_set(shader);
			shader_set_uniform_f_array(uniform_dim, _dim);
			shader_set_uniform_f_array(uniform_pos, _pos);
			shader_set_uniform_f_array(uniform_sca, _sca);
			shader_set_uniform_f(uniform_bri, _bri);
			shader_set_uniform_i(uniform_ite, _ite);
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
}