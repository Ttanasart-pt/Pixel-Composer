function Node_Stripe(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Stripe";
	
	shader = sh_stripe;
	uniform_grad_use = shader_get_uniform(shader, "gradient_use");
	uniform_grad_blend = shader_get_uniform(shader, "gradient_blend");
	uniform_grad = shader_get_uniform(shader, "gradient_color");
	uniform_grad_time = shader_get_uniform(shader, "gradient_time");
	uniform_grad_key = shader_get_uniform(shader, "gradient_keys");
	
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_angle = shader_get_uniform(shader, "angle");
	uniform_amount = shader_get_uniform(shader, "amount");
	uniform_blend = shader_get_uniform(shader, "blend");
	uniform_rand = shader_get_uniform(shader, "rand");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [1, 16, 0.1]);
	
	inputs[| 2] = nodeValue(2, "Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 3] = nodeValue(3, "Blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 0);
	
	inputs[| 4] = nodeValue(4, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0] )
		.setDisplay(VALUE_DISPLAY.vector);
		
	inputs[| 5] = nodeValue(5, "Random", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
		
	inputs[| 6] = nodeValue(6, "Random color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 7] = nodeValue(7, "Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white)
		.setDisplay(VALUE_DISPLAY.gradient);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [ 
		["Output",	true],	0,  
		["Pattern",	false], 1, 2, 4, 5,
		["Render",	false], 3, 6, 7
	];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos = inputs[| 4].getValue();
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| 2].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _dim = _data[0];
		var _amo = _data[1];
		var _ang = _data[2];
		var _bnd = _data[3];
		var _pos = _data[4];
		var _rnd = _data[5];
		
		var _grad_use = _data[6];
		inputs[| 7].setVisible(_grad_use);
		
		var _gra = _data[7];
		var _gra_data = inputs[| 7].getExtraData();
		
		var _g = getGradientData(_gra, _gra_data);
		var _grad_color = _g[0];
		var _grad_time = _g[1];
		
		if(!is_surface(_outSurf))
			_outSurf =  surface_create_valid(_dim[0], _dim[1]);
		else
			surface_size_to(_outSurf, _dim[0], _dim[1]);
			
		surface_set_target(_outSurf);
			shader_set(shader);
			shader_set_uniform_f(uniform_dim, _dim[0], _dim[1]);
			shader_set_uniform_f(uniform_pos, _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_uniform_f(uniform_angle,  degtorad(_ang));
			shader_set_uniform_f(uniform_amount, _amo);
			shader_set_uniform_f(uniform_blend, _bnd);
			shader_set_uniform_f(uniform_rand, _rnd);
			
			shader_set_uniform_i(uniform_grad_use, _grad_use);
			shader_set_uniform_i(uniform_grad_blend, ds_list_get(_gra_data, 0));
			shader_set_uniform_f_array(uniform_grad, _grad_color);
			shader_set_uniform_f_array(uniform_grad_time, _grad_time);
			shader_set_uniform_i(uniform_grad_key, ds_list_size(_gra));
			
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
			shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
	doUpdate();
}