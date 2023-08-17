function Node_Cellular(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Cellular Noise";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ DEF_SURF_W / 2, DEF_SURF_H / 2])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4);
	
	inputs[| 3] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 4] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Point", "Edge", "Cell", "Crystal" ]);
	
	inputs[| 5] = nodeValue("Contrast", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 6] = nodeValue("Pattern", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Radial" ]);
	
	inputs[| 7] = nodeValue("Middle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [0., 1., 0.01]);
	
	inputs[| 8] = nodeValue("Radial scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2)
		.setDisplay(VALUE_DISPLAY.slider, [1., 10., 0.01]);
	
	inputs[| 9] = nodeValue("Radial shatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-10., 10., 0.01])
		.setVisible(false);
	
	inputs[| 10] = nodeValue("Colored", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
	
	input_display_list = [
		["Output",		false], 0, 
		["Noise",		false], 4, 6, 3, 1, 2, 
		["Radial",		false], 8, 9,
		["Rendering",	false], 5, 7, 10, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim  = _data[0];
		var _pos  = _data[1];
		var _sca  = _data[2];
		var _tim  = _data[3];
		var _type = _data[4];
		var _con  = _data[5];
		var _pat  = _data[6];
		var _mid  = _data[7];
		
		inputs[|  8].setVisible(_pat == 1);
		inputs[|  9].setVisible(_pat == 1);
		inputs[| 10].setVisible(_type == 2);
		
		var _rad = _data[ 8];
		var _sht = _data[ 9];
		var _col = _data[10];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
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
		uniform_col = shader_get_uniform(shader, "colored");
		
		surface_set_target(_outSurf);
		shader_set(shader);
			shader_set_uniform_f_array_safe(uniform_dim, _dim);
			shader_set_uniform_f(uniform_tim, _tim);
			shader_set_uniform_f_array_safe(uniform_pos, _pos);
			shader_set_uniform_f(uniform_sca, _sca);
			shader_set_uniform_f(uniform_con, _con);
			shader_set_uniform_f(uniform_mid, _mid);
			shader_set_uniform_f(uniform_rad, _rad);
			shader_set_uniform_f(uniform_sht, _sht);
			shader_set_uniform_i(uniform_pat, _pat);
			shader_set_uniform_i(uniform_col, _col);
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
}