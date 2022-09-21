function Node_create_Normal_Light(_x, _y) {
	var node = new Node_Normal_Light(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Normal_Light(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Normal Light";
	
	uniform_map = shader_get_sampler_index(sh_normal_light, "normalMap");
	uniform_hei = shader_get_uniform(sh_normal_light, "normalHeight");
	uniform_dim = shader_get_uniform(sh_normal_light, "dimension");
	
	uniform_amb = shader_get_uniform(sh_normal_light, "ambiance");
	uniform_light_pos = shader_get_uniform(sh_normal_light, "lightPosition");
	uniform_light_col = shader_get_uniform(sh_normal_light, "lightColor");
	uniform_light_int = shader_get_uniform(sh_normal_light, "lightIntensity");
	uniform_light_typ = shader_get_uniform(sh_normal_light, "lightType");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Normal map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 2] = nodeValue(2, "Normal intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	inputs[| 3] = nodeValue(3, "Ambient", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 4] = nodeValue(4, "Light position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, -1 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 5] = nodeValue(5, "Light range", self,	JUNCTION_CONNECT.input, VALUE_TYPE.float, 16);
	inputs[| 6] = nodeValue(6, "Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	inputs[| 7] = nodeValue(7, "Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 8] = nodeValue(8, "Light type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, ["Point", "Sun"]);
	
	input_display_list = [ 0, 
		["Normal",	false], 1, 2, 
		["Light",	false], 3, 8, 4, 5, 6, 7
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		var pos = inputs[| 4].getValue();
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 4].drawOverlay(_active, _x, _y, _s, _mx, _my);
		inputs[| 5].drawOverlay(_active, px, py, _s, _mx, _my);
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _map = _data[1];
		var _hei = _data[2];
		var _amb = _data[3];
		
		var _light_pos = _data[4];
		var _light_ran = _data[5];
		var _light_int = _data[6];
		var _light_col = _data[7];
		var _light_typ = _data[8];
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_ADD 
		
			shader_set(sh_normal_light);
			texture_set_stage(uniform_map, surface_get_texture(_map));
			shader_set_uniform_f(uniform_hei, _hei);
			shader_set_uniform_f_array(uniform_dim, [ surface_get_width(_data[0]), surface_get_height(_data[0]) ]);
			shader_set_uniform_f_array(uniform_amb, [color_get_red(_amb) / 255, color_get_green(_amb) / 255, color_get_blue(_amb) / 255]);
			
			shader_set_uniform_f_array(uniform_light_pos, [ _light_pos[0], _light_pos[1], _light_pos[2], _light_ran ] );
			shader_set_uniform_f_array(uniform_light_col, [color_get_red(_light_col) / 255, color_get_green(_light_col) / 255, color_get_blue(_light_col) / 255]);
			shader_set_uniform_f(uniform_light_int, _light_int);
			shader_set_uniform_i(uniform_light_typ, _light_typ);
			
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
			
			BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}