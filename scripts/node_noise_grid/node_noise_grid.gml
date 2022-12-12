function Node_create_Grid_Noise(_x, _y) {
	var node = new Node_Grid_Noise(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Grid_Noise(_x, _y) : Node(_x, _y) constructor {
	name = "Grid noise";
	
	shader = sh_grid_noise;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_sca = shader_get_uniform(shader, "scale");
	uniform_sed = shader_get_uniform(shader, "seed");
	uniform_shf = shader_get_uniform(shader, "shift");
	
	uniform_sam = shader_get_uniform(shader, "useSampler");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 8, 8 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 4] = nodeValue(4, "X shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-2, 2, 0.01]);
		
	inputs[| 5] = nodeValue(5, "Texture sample", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	input_display_list = [
		["Ouptut", false], 0,
		["Effect", false], 3, 1, 2, 4, 
		["Render", false], 5, 
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my);
	}
	
	static update = function() {
		var _dim = inputs[| 0].getValue();
		var _pos = inputs[| 1].getValue();
		var _sca = inputs[| 2].getValue();
		var _sed = inputs[| 3].getValue();
		var _shf = inputs[| 4].getValue();
		var _sam = inputs[| 5].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf =  surface_create_valid(_dim[0], _dim[1]);
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		shader_set(shader);
			shader_set_uniform_f_array(uniform_dim, _dim);
			shader_set_uniform_f_array(uniform_pos, _pos);
			shader_set_uniform_f_array(uniform_sca, _sca);
			shader_set_uniform_i(uniform_sam, is_surface(_sam));
			shader_set_uniform_f(uniform_shf, _shf);
			
			random_set_seed(_sed);
			shader_set_uniform_f(uniform_sed, random_range(1.0, 10.0));
			if(is_surface(_sam))
				draw_surface_stretched(_sam, 0, 0, _dim[0], _dim[1]);
			else
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
	}
	doUpdate();
}