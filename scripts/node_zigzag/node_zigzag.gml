function Node_Zigzag(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Zigzag";
	
	shader = sh_zigzag;
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_amo = shader_get_uniform(shader, "amount");
	uniform_bnd = shader_get_uniform(shader, "blend");
	
	uniform_col1 = shader_get_uniform(shader, "col1");
	uniform_col2 = shader_get_uniform(shader, "col2");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.slider, [1, 16, 0.1]);
		
	inputs[| 2] = nodeValue(2, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Color 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 4] = nodeValue(4, "Color 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 5] = nodeValue(5, "Smooth", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [
		["Output",  false], 0,
		["Pattern",	false], 1, 2,
		["Render",	false], 3, 4, 5,
	];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static update = function() {
		var _dim = inputs[| 0].getValue();
		var _amo = inputs[| 1].getValue();
		var _pos = inputs[| 2].getValue();
		
		var _col1 = inputs[| 3].getValue();
		var _col2 = inputs[| 4].getValue();
		var _bnd  = inputs[| 5].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf =  surface_create_valid(_dim[0], _dim[1]);
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, _dim[0], _dim[1]);
			
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
			shader_set(shader);
			shader_set_uniform_f(uniform_pos, _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_uniform_f(uniform_amo, _amo);
			shader_set_uniform_f_array(uniform_col1, colToVec4(_col1));
			shader_set_uniform_f_array(uniform_col2, colToVec4(_col2));
			shader_set_uniform_i(uniform_bnd, _bnd);
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
			shader_reset();
		surface_reset_target();
	}
	doUpdate();
}