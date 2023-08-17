function Node_Stripe(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
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
	
	uniform_clr0 = shader_get_uniform(shader, "color0");
	uniform_clr1 = shader_get_uniform(shader, "color1");
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [1, 16, 0.1]);
	
	inputs[| 2] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 3] = nodeValue("Blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 0, "Smoothly blend between each stripe.");
	
	inputs[| 4] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		
	inputs[| 5] = nodeValue("Random", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
		
	inputs[| 6] = nodeValue("Random color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 7] = nodeValue("Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) );
	
	inputs[| 8] = nodeValue("Color 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 9] = nodeValue("Color 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 
		["Output",	true],	0,  
		["Pattern",	false], 1, 2, 4, 5,
		["Render",	false], 6, 7, 8, 9, 3
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos = inputs[| 4].getValue();
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| 2].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _amo = _data[1];
		var _ang = _data[2];
		var _bnd = _data[3];
		var _pos = _data[4];
		var _rnd = _data[5];
		
		var _clr0 = _data[8];
		var _clr1 = _data[9];
		
		var _grad_use = _data[6];
		inputs[| 7].setVisible(_grad_use);
		inputs[| 8].setVisible(!_grad_use);
		inputs[| 9].setVisible(!_grad_use);
		
		var _gra = _data[7];
		
		var _g = _gra.toArray();
		var _grad_color = _g[0];
		var _grad_time = _g[1];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
			
		surface_set_target(_outSurf);
			shader_set(shader);
			shader_set_uniform_f(uniform_dim, _dim[0], _dim[1]);
			shader_set_uniform_f(uniform_pos, _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_uniform_f(uniform_angle,  degtorad(_ang));
			shader_set_uniform_f(uniform_amount, _amo);
			shader_set_uniform_f(uniform_blend, _bnd);
			shader_set_uniform_f(uniform_rand, _rnd);
			
			shader_set_uniform_f_array_safe(uniform_clr0, colToVec4(_clr0));
			shader_set_uniform_f_array_safe(uniform_clr1, colToVec4(_clr1));
			
			shader_set_uniform_i(uniform_grad_use, _grad_use);
			shader_set_uniform_i(uniform_grad_blend, _gra.type);
			shader_set_uniform_f_array_safe(uniform_grad, _grad_color);
			shader_set_uniform_f_array_safe(uniform_grad_time, _grad_time);
			shader_set_uniform_i(uniform_grad_key, array_length(_gra.keys));
			
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
			shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
}