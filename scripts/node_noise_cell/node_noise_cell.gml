function Node_create_Cellular(_x, _y) {
	var node = new Node_Cellular(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Cellular(_x, _y) : Node(_x, _y) constructor {
	name = "Cellular";
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2])
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(false);
	
	inputs[| 2] = nodeValue(2, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4)
		.setVisible(false);
	
	inputs[| 3] = nodeValue(3, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(false);
	
	inputs[| 4] = nodeValue(4, "Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Point", "Edge", "Cell" ])
		.setVisible(false);
	
	inputs[| 5] = nodeValue(5, "Contrast", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setVisible(false);
	
	inputs[| 6] = nodeValue(6, "Pattern", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Uniform", "Radial" ])
		.setVisible(false);
	
	inputs[| 7] = nodeValue(7, "Middle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [0., 1., 0.01])
		.setVisible(false);
	
	inputs[| 8] = nodeValue(8, "Radial scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2)
		.setDisplay(VALUE_DISPLAY.slider, [1., 10., 0.01])
		.setVisible(false, false);
	
	inputs[| 9] = nodeValue(9, "Radial shatter", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-10., 10., 0.01])
		.setVisible(false, false);
	
	input_display_list = [
		["Output",		false], 0, 
		["Noise",		false], 4, 6, 3, 1, 2, 
		["Radial",		false], 8, 9,
		["Rendering",	false], 5, 7
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		inputs[| 1].drawOverlay(_active, _x, _y, _s, _mx, _my);
	}
	
	static update = function() {
		var _dim = inputs[| 0].getValue();
		var _pos = inputs[| 1].getValue();
		var _sca = inputs[| 2].getValue();
		var _tim = inputs[| 3].getValue();
		var _type = inputs[| 4].getValue();
		var _con = inputs[| 5].getValue();
		var _pat = inputs[| 6].getValue();
		var _mid = inputs[| 7].getValue();
		
		inputs[| 8].show_in_inspector = _pat == 1;
		inputs[| 9].show_in_inspector = _pat == 1;
		var _rad = inputs[| 8].getValue();
		var _sht = inputs[| 9].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf = surface_create(surface_valid(_dim[0]), surface_valid(_dim[1]));
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, surface_valid(_dim[0]), surface_valid(_dim[1]));
		
		if(_type == 0) {
			shader = sh_cell_noise;
		} else if(_type == 1) {
			shader = sh_cell_noise_edge;	
		} else if(_type == 2) {
			shader = sh_cell_noise_random;	
		}
		
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
	}
	doUpdate();
}