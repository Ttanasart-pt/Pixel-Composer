function Node_Checker(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Checker";
	
	shader = sh_checkerboard;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_angle = shader_get_uniform(shader, "angle");
	uniform_amount = shader_get_uniform(shader, "amount");
	
	uniform_col1 = shader_get_uniform(shader, "col1");
	uniform_col2 = shader_get_uniform(shader, "col2");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2)
		.setDisplay(VALUE_DISPLAY.slider, [2, 16, 0.1]);
	
	inputs[| 2] = nodeValue(2, "Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 3] = nodeValue(3, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue(4, "Color 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 5] = nodeValue(5, "Color 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [
		["Output",	true],	0,  
		["Pattern",	false], 1, 2, 3,
		["Render",	false], 4, 5,
	];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var pos = inputs[| 3].getValue();
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| 2].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny);
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _dim = _data[0];
		var _amo = _data[1];
		var _ang = _data[2];
		var _pos = _data[3];
		
		var _col1 = _data[4];
		var _col2 = _data[5];
		
		if(!is_surface(_outSurf))
			_outSurf =  surface_create_valid(_dim[0], _dim[1]);
		else
			surface_size_to(_outSurf, _dim[0], _dim[1]);
			
		surface_set_target(_outSurf);
			shader_set(shader);
			shader_set_uniform_f(uniform_dim, surface_get_width(_outSurf), surface_get_height(_outSurf));
			shader_set_uniform_f(uniform_pos, _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_uniform_f(uniform_angle,  degtorad(_ang));
			shader_set_uniform_f(uniform_amount, _amo);
			shader_set_uniform_f_array(uniform_col1, colToVec4(_col1));
			shader_set_uniform_f_array(uniform_col2, colToVec4(_col2));
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
			shader_reset();
		surface_reset_target();
		
		return _outSurf;
	}
	doUpdate();
}