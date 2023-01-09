function Node_Grid_Noise(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Grid noise";
	
	shader = sh_grid_noise;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_sca = shader_get_uniform(shader, "scale");
	uniform_sed = shader_get_uniform(shader, "seed");
	uniform_shf = shader_get_uniform(shader, "shift");
	uniform_shfax = shader_get_uniform(shader, "shiftAxis");
	
	uniform_sam = shader_get_uniform(shader, "useSampler");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue(2, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 8, 8 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0);
	
	inputs[| 4] = nodeValue(4, "Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-2, 2, 0.01]);
		
	inputs[| 5] = nodeValue(5, "Texture sample", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 6] = nodeValue(6, "Shift axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, ["x", "y"]);
	
	input_display_list = [
		["Ouptut",	false], 0,
		["Noise",	false], 3, 1, 2, 6, 4, 
		["Render",	false], 5, 
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		var _sca = _data[2];
		var _sed = _data[3];
		var _shf = _data[4];
		var _sam = _data[5];
		var _shfAx = _data[6];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		shader_set(shader);
			shader_set_uniform_f_array(uniform_dim, _dim);
			shader_set_uniform_f_array(uniform_pos, _pos);
			shader_set_uniform_f_array(uniform_sca, _sca);
			shader_set_uniform_i(uniform_sam, is_surface(_sam));
			shader_set_uniform_f(uniform_shf, _shf);
			shader_set_uniform_i(uniform_shfax, _shfAx);
			shader_set_uniform_f(uniform_sed, _sed);
			
			if(is_surface(_sam))
				draw_surface_stretched(_sam, 0, 0, _dim[0], _dim[1]);
			else
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
}