function Node_create_Color_Remove(_x, _y) {
	var node = new Node_Color_Remove(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Color_Remove(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Color Remove";
	
	uniform_from       = shader_get_uniform(sh_color_remove, "colorFrom");
	uniform_from_count = shader_get_uniform(sh_color_remove, "colorFrom_amo");
	
	uniform_ter  = shader_get_uniform(sh_color_remove, "treshold");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [ c_black ])
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 2] = nodeValue(2, "Treshold",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	static process_data = function(_outSurf, _data, _output_index) {
		var fr = _data[1];
		var tr = _data[2];
		
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
		
		shader_set(sh_color_remove);
			shader_set_uniform_f_array(uniform_from, _colors);
			shader_set_uniform_i(uniform_from_count, array_length(fr));
			
			shader_set_uniform_f(uniform_ter, tr);
			
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		return _outSurf;
	}
}