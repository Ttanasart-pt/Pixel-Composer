function Node_Cellular(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Cellular";
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue(2, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4);
	
	inputs[| 3] = nodeValue(3, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 4] = nodeValue(4, "Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Point", "Edge", "Cell", "Crystal" ]);
	
	inputs[| 5] = nodeValue(5, "Contrast", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 6] = nodeValue(6, "Pattern", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Radial" ]);
	
	inputs[| 7] = nodeValue(7, "Middle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [0., 1., 0.01]);
	
	inputs[| 8] = nodeValue(8, "Radial scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2)
		.setDisplay(VALUE_DISPLAY.slider, [1., 10., 0.01]);
	
	inputs[| 9] = nodeValue(9, "Radial shatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-10., 10., 0.01])
		.setVisible(false);
	
	input_display_list = [
		["Output",		false], 0, 
		["Noise",		false], 4, 6, 3, 1, 2, 
		["Radial",		false], 8, 9,
		["Rendering",	false], 5, 7
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dim  = _data[0];
		var _pos  = _data[1];
		var _sca  = _data[2];
		var _tim  = _data[3];
		var _type = _data[4];
		var _con  = _data[5];
		var _pat  = _data[6];
		var _mid  = _data[7];
		
		inputs[| 8].setVisible(_pat == 1);
		inputs[| 9].setVisible(_pat == 1);
		var _rad = _data[8];
		var _sht = _data[9];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		if(_type == 0)
			shader = sh_cell_noise;
		else if(_type == 1)
			shader = sh_cell_noise_edge;	
		else if(_type == 2)
			shader = sh_cell_noise_random;	
		else if(_type == 3)
			shader = sh_cell_noise_crystal;	
		
		uniform_dim = shader_get_uniform(shader, "dimension");
		uniform_pos = shader_get_uniform(shader, "position");
		uniform_sca = shader_get_uniform(shader, "scale");
		uniform_tim = shader_get_uniform(shader, "time");
		uniform_con = shader_get_uniform(shader, "contrast");
		uniform_pat = shader_get_uniform(shader, "pattern");
		uniform_mid = shader_get_uniform(shader, "middle");
		
		uniform_rad = shader_get_uniform(shader, "radiusScale");
		uniform_sht = shader_get_uniform(shader, "radiusShatter");
		
		surface_set_target(_outSurf);
		shader_set(shader);
			shader_set_uniform_f_array(uniform_dim, _dim);
			shader_set_uniform_f(uniform_tim, _tim);
			shader_set_uniform_f_array(uniform_pos, _pos);
			shader_set_uniform_f(uniform_sca, _sca);
			shader_set_uniform_f(uniform_con, _con);
			shader_set_uniform_f(uniform_mid, _mid);
			shader_set_uniform_f(uniform_rad, _rad);
			shader_set_uniform_f(uniform_sht, _sht);
			shader_set_uniform_i(uniform_pat, _pat);
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
}