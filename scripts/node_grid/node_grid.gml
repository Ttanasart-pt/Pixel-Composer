function Node_create_Grid(_x, _y) {
	var node = new Node_Grid(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Grid(_x, _y) : Node(_x, _y) constructor {
	name = "Grid";
	
	shader = sh_grid;
	uniform_pos = shader_get_uniform(shader, "position");
	uniform_dim = shader_get_uniform(shader, "dimension");
	uniform_sca = shader_get_uniform(shader, "scale");
	uniform_wid = shader_get_uniform(shader, "width");
	uniform_ang = shader_get_uniform(shader, "angle");
	uniform_shf = shader_get_uniform(shader, "shift");
	uniform_shx = shader_get_uniform(shader, "shiftAxis");
	
	uniform_col1 = shader_get_uniform(shader, "col1");
	uniform_col2 = shader_get_uniform(shader, "col2");
	uniform_sam = shader_get_uniform(shader, "useSampler");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue(2, "Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue(3, "Gap", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.02)
		.setDisplay(VALUE_DISPLAY.slider, [0, 0.5, 0.01]);
	
	inputs[| 4] = nodeValue(4, "Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 5] = nodeValue(5, "Color 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	inputs[| 6] = nodeValue(6, "Color 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 7] = nodeValue(7, "Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 8] = nodeValue(8, "Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-0.5, 0.5, 0.01]);
		
	inputs[| 9] = nodeValue(9, "Shift axis", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, ["X", "Y"]);
	
	input_display_list = [
		["Output",  false], 0,
		["Pattern",	false], 1, 4, 2, 3, 9, 8,
		["Render",	false], 5, 6, 7,
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
		inputs[| 1].drawOverlay(active, _x, _y, _s, _mx, _my);
	}
	
	static update = function() {
		var _dim = inputs[| 0].getValue();
		var _pos = inputs[| 1].getValue();
		var _sca = inputs[| 2].getValue();
		var _wid = inputs[| 3].getValue();
		var _ang = inputs[| 4].getValue();
		var _sam = inputs[| 7].getValue();
		var _shf = inputs[| 8].getValue();
		var _shx = inputs[| 9].getValue();
		
		var _col1 = inputs[| 5].getValue();
		var _col2 = inputs[| 6].getValue();
		
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
			shader_set_uniform_f(uniform_dim, _dim[0], _dim[1]);
			shader_set_uniform_f_array(uniform_sca, _sca);
			shader_set_uniform_f(uniform_wid, _wid);
			shader_set_uniform_f(uniform_ang, degtorad(_ang));
			shader_set_uniform_f(uniform_sam, is_surface(_sam));
			shader_set_uniform_f(uniform_shf, _shf);
			shader_set_uniform_i(uniform_shx, _shx);
			shader_set_uniform_f_array(uniform_col1, colToVec4(_col1));
			shader_set_uniform_f_array(uniform_col2, colToVec4(_col2));
			
			if(is_surface(_sam))
				draw_surface_stretched(_sam, 0, 0, _dim[0], _dim[1]);
			else
				draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		shader_reset();
		surface_reset_target();
	}
	doUpdate();
}