function Node_create_Cellular(_x, _y) {
	var node = new Node_Cellular(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Cellular(_x, _y) : Node(_x, _y) constructor {
	name = "Cellular";
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4);
	
	inputs[| 3] = nodeValue(3, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 4] = nodeValue(4, "Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Point", "Edge", "Cell", "Rounded" ]);
	
	//inputs[| 5] = nodeValue(5, "Width", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2);
	//inputs[| 5].setDisplay(VALUE_DISPLAY.slider, [0., 1., 0.01]);
	
	input_display_list = [
		["Output",	false], 0, 
		["Noise",	false], 4, 3, 1, 2
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	function update() {
		var _dim = inputs[| 0].getValue();
		var _pos = inputs[| 1].getValue();
		var _sca = inputs[| 2].getValue();
		var _tim = inputs[| 3].getValue();
		var _type = inputs[| 4].getValue();
		
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
		} else if(_type == 2) {
			shader = sh_cell_noise_round;	
		}
		
		uniform_pos = shader_get_uniform(shader, "position");
		uniform_sca = shader_get_uniform(shader, "scale");
		uniform_tim = shader_get_uniform(shader, "time");
		
		surface_set_target(_outSurf);
		shader_set(shader);
			shader_set_uniform_f(uniform_tim, _tim);
			shader_set_uniform_f_array(uniform_pos, _pos);
			shader_set_uniform_f(uniform_sca, _sca);
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
	}
	update();
}