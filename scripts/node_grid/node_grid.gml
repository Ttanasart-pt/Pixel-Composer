function Node_create_Grid(_x, _y) {
	var node = new Node_Grid(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Grid(_x, _y) : Node(_x, _y) constructor {
	name = "Grid";
	
	shader = sh_grid;
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_sca = shader_get_uniform(shader, "scale");
	uniform_wid = shader_get_uniform(shader, "width");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Gap", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.02)
		.setDisplay(VALUE_DISPLAY.slider, [0, 0.5, 0.01]);
	
	input_display_list = [
		["Effect settings", false], 0, 1, 2, 3
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	function update() {
		var _dim = inputs[| 0].getValue();
		var _pos = inputs[| 1].getValue();
		var _sca = inputs[| 2].getValue();
		var _wid = inputs[| 3].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf = surface_create(surface_valid(_dim[0]), surface_valid(_dim[1]));
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, surface_valid(_dim[0]), surface_valid(_dim[1]));
		
		surface_set_target(_outSurf);
		shader_set(shader);
			shader_set_uniform_f_array(uniform_pos, _pos);
			shader_set_uniform_f_array(uniform_sca, _sca);
			shader_set_uniform_f(uniform_wid, _wid);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
	}
	update();
}