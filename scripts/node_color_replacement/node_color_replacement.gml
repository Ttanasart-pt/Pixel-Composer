function Node_create_Color_replace(_x, _y) {
	var node = new Node_Color_replace(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Color_replace(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Color replace";
	
	uniform_from       = shader_get_uniform(sh_color_replace, "colorFrom");
	uniform_from_count = shader_get_uniform(sh_color_replace, "colorFrom_amo");
	
	uniform_to   = shader_get_uniform(sh_color_replace, "colorTo");
	uniform_ter  = shader_get_uniform(sh_color_replace, "treshold");
	uniform_alp  = shader_get_uniform(sh_color_replace, "alphacmp");
	uniform_inv  = shader_get_uniform(sh_color_replace, "inverted");
	uniform_hrd  = shader_get_uniform(sh_color_replace, "hardReplace");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Color from", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [ c_black ])
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 2] = nodeValue(2, "Color to", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 3] = nodeValue(3, "Treshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 4] = nodeValue(4, "Set others to black", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 5] = nodeValue(5, "Multiply alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 6] = nodeValue(6, "Hard replace", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	input_display_list = [0, 
		["Color",		false], 1, 2, 
		["Comparison",	false], 3, 5, 
		["Render",		false], 4, 6
	];
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	static process_data = function(_outSurf, _data, _output_index) {
		var fr = _data[1];
		var to = _data[2];
		var tr = _data[3];
		var in = _data[4];
		var alp = _data[5];
		var hrd = _data[6];
		
		var _colors = array_create(array_length(fr) * 4);
		for(var i = 0; i < array_length(fr); i++) {
			_colors[i * 4 + 0] = color_get_red(fr[i]) / 255;
			_colors[i * 4 + 1] = color_get_green(fr[i]) / 255;
			_colors[i * 4 + 2] = color_get_blue(fr[i]) / 255;
			_colors[i * 4 + 3] = 1;
		}
		
		surface_set_target(_outSurf);
		draw_clear_alpha(0, 0);
		BLEND_ADD
		
		shader_set(sh_color_replace);
			shader_set_uniform_f_array(uniform_from, _colors);
			shader_set_uniform_i(uniform_from_count, array_length(fr));
			shader_set_uniform_i(uniform_alp, alp);
			shader_set_uniform_i(uniform_hrd, hrd);
			
			shader_set_uniform_f_array(uniform_to, [ color_get_red(to) / 255, color_get_green(to) / 255, color_get_blue(to) / 255, 1.0 ] );
			shader_set_uniform_f(uniform_ter, tr);
			shader_set_uniform_i(uniform_inv, in);
			
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}