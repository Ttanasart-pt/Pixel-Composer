function Node_Gradient(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Gradient";
	
	shader = sh_gradient;
	uniform_grad_blend	= shader_get_uniform(shader, "gradient_blend");
	uniform_grad		= shader_get_uniform(shader, "gradient_color");
	uniform_grad_time	= shader_get_uniform(shader, "gradient_time");
	uniform_grad_key	= shader_get_uniform(shader, "gradient_keys");
	uniform_grad_loop	= shader_get_uniform(shader, "gradient_loop");
	
	uniform_type		= shader_get_uniform(shader, "type");
	uniform_center		= shader_get_uniform(shader, "center");
	
	uniform_angle		= shader_get_uniform(shader, "angle");
	uniform_radius		= shader_get_uniform(shader, "radius");
	uniform_radius_shf	= shader_get_uniform(shader, "shift");
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [ new gradientKey(0, c_white) ] )
		.setDisplay(VALUE_DISPLAY.gradient);
	
	inputs[| 2] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Linear", "Circular", "Radial" ]);
	
	inputs[| 3] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);

	inputs[| 4] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, .5);
		
	inputs[| 5] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-2, 2, 0.01]);
	
	inputs[| 6] = nodeValue("Center", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [def_surf_size / 2, def_surf_size / 2])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 7] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 8] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output",		true],	0, 8, 
		["Gradient",	false], 1, 5, 7,
		["Shape",		false], 2, 3, 4, 6
	];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 6].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
			
		var _gra = _data[1];
		var _gra_data = inputs[| 1].getExtraData();
		
		var _typ = _data[2];
		var _ang = _data[3];
		var _rad = _data[4];
		var _shf = _data[5];
		var _cnt = _data[6];
		var _lop = _data[7];
		var _msk = _data[8];
		
		var _grad = gradient_to_array(_gra);
		var _grad_color = _grad[0];
		var _grad_time	= _grad[1];
		
		if(_typ == 0 || _typ == 2) {
			inputs[| 3].setVisible(true);
			inputs[| 4].setVisible(false);
		} else if(_typ == 1) {
			inputs[| 3].setVisible(false);
			inputs[| 4].setVisible(true);
		}
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		shader_set(shader);
			shader_set_uniform_i(uniform_grad_blend, ds_list_get(_gra_data, 0));
			shader_set_uniform_f_array_safe(uniform_grad, _grad_color);
			shader_set_uniform_f_array_safe(uniform_grad_time, _grad_time);
			shader_set_uniform_i(uniform_grad_key, array_length(_gra));
			shader_set_uniform_i(uniform_grad_loop, _lop);
			
			shader_set_uniform_f_array_safe(uniform_center, [_cnt[0] / _dim[0], _cnt[1] / _dim[1]]);
			shader_set_uniform_i(uniform_type, _typ);
			
			shader_set_uniform_f(uniform_angle, degtorad(_ang));
			shader_set_uniform_f(uniform_radius, _rad * sqrt(2));
			shader_set_uniform_f(uniform_radius_shf, _shf);
			
			BLEND_OVERRIDE;
			if(is_surface(_msk))
				draw_surface_stretched_ext(_msk, 0, 0, _dim[0], _dim[1], c_white, 1);
			else
				draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], c_white, 1);
			BLEND_NORMAL;
		shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
}