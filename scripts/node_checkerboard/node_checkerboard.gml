function Node_create_Checker(_x, _y) {
	var node = new Node_Checker(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Checker(_x, _y) : Node(_x, _y) constructor {
	name = "Checker";
	
	uniform_pos = shader_get_uniform(sh_checkerboard, "position");
	uniform_angle = shader_get_uniform(sh_checkerboard, "angle");
	uniform_amount = shader_get_uniform(sh_checkerboard, "amount");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2)
		.setDisplay(VALUE_DISPLAY.slider, [2, 32, 1]);
	
	inputs[| 2] = nodeValue(2, "Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 3] = nodeValue(3, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		var pos = inputs[| 3].getValue();
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 3].drawOverlay(_active, _x, _y, _s, _mx, _my);
		inputs[| 2].drawOverlay(_active, px, py, _s, _mx, _my);
	}
	
	function update() {
		var _dim = inputs[| 0].getValue();
		var _amo = inputs[| 1].getValue();
		var _ang = inputs[| 2].getValue();
		var _pos = inputs[| 3].getValue();
		
		var _outSurf = outputs[| 0].getValue();
		if(!is_surface(_outSurf)) {
			_outSurf = surface_create(surface_valid(_dim[0]), surface_valid(_dim[1]));
			outputs[| 0].setValue(_outSurf);
		} else
			surface_size_to(_outSurf, surface_valid(_dim[0]), surface_valid(_dim[1]));
			
		surface_set_target(_outSurf);
			shader_set(sh_checkerboard);
			shader_set_uniform_f(uniform_pos, _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_uniform_f(uniform_angle,  degtorad(_ang));
			shader_set_uniform_f(uniform_amount, _amo);
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
			shader_reset();
		surface_reset_target();
	}
	doUpdate();
}