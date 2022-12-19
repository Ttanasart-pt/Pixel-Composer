function Node_Gradient_Points(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "4 Points gradient";
	
	shader = sh_gradient_points;
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_cen = shader_get_uniform(shader, "center");
	uniform_col = shader_get_uniform(shader, "color");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Center 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	inputs[| 2] = nodeValue(2, "Color 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 3] = nodeValue(3, "Center 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	inputs[| 4] = nodeValue(4, "Color 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 5] = nodeValue(5, "Center 3", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, def_surf_size ] )
		.setDisplay(VALUE_DISPLAY.vector);
	inputs[| 6] = nodeValue(6, "Color 3", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 7] = nodeValue(7, "Center 4", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size, def_surf_size ] )
		.setDisplay(VALUE_DISPLAY.vector);
	inputs[| 8] = nodeValue(8, "Color 4", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [
		["Output",		true],	0,
		["Positions",	false],	1, 3, 5, 7,
		["Colors",		false],	2, 4, 6, 8,
	];
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[| 5].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
		if(inputs[| 7].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny)) active = false;
	}
	
	static update = function() {
		var _dim = inputs[| 0].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf =  surface_create_valid(_dim[0], _dim[1]);
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, _dim[0], _dim[1]);
			
		var _1cen = inputs[| 1].getValue();
		var _1col = inputs[| 2].getValue();
		var _2cen = inputs[| 3].getValue();
		var _2col = inputs[| 4].getValue();
		var _3cen = inputs[| 5].getValue();
		var _3col = inputs[| 6].getValue();
		var _4cen = inputs[| 7].getValue();
		var _4col = inputs[| 8].getValue();
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		shader_set(shader);
			shader_set_uniform_f_array(uniform_dim, [_dim[0], _dim[1]]);
			shader_set_uniform_f_array(uniform_cen, array_merge(_1cen, _2cen, _3cen, _4cen));
			shader_set_uniform_f_array(uniform_col, array_merge(colorArrayFromReal(_1col), colorArrayFromReal(_2col), colorArrayFromReal(_3col), colorArrayFromReal(_4col)));
			
			draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], c_white, 1);
		shader_reset();
		surface_reset_target();
	}
	doUpdate();
}