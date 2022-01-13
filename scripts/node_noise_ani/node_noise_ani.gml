function Node_create_Noise_Aniso(_x, _y) {
	var node = new Node_Noise_Aniso(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Noise_Aniso(_x, _y) : Node(_x, _y) constructor {
	name = "Noise Anisotropic";
	
	shader = sh_ani_noise;
	uniform_noi = shader_get_uniform(shader, "noiseAmount");
	uniform_sed = shader_get_uniform(shader, "seed");
	uniform_pos = shader_get_uniform(shader, "position");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 2, 16 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom(9999999));
	
	inputs[| 3] = nodeValue(3, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	input_display_list = [
		["Output",	false], 0, 
		["Noise",	false], 2, 1, 3
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	function update() {
		var _dim = inputs[| 0].getValue();
		var _amo = inputs[| 1].getValue();
		var _sed = inputs[| 2].getValue();
		var _pos = inputs[| 3].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf = surface_create(surface_valid(_dim[0]), surface_valid(_dim[1]));
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, surface_valid(_dim[0]), surface_valid(_dim[1]));
		
		surface_set_target(_outSurf);
		shader_set(shader);
			shader_set_uniform_f_array(uniform_noi, _amo);
			shader_set_uniform_f_array(uniform_pos, _pos);
			shader_set_uniform_f(uniform_sed, _sed);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
	}
	update();
}