function Node_Posterize(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Posterize";
	
	uniform_colors = shader_get_uniform(sh_posterize, "colors");
	uniform_gamma = shader_get_uniform(sh_posterize, "gamma");
	
	uniform_color = shader_get_uniform(sh_posterize_palette, "palette");
	uniform_key = shader_get_uniform(sh_posterize_palette, "keys");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 2] = nodeValue("Use palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 3] = nodeValue("Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4)
		.setDisplay(VALUE_DISPLAY.slider, [2, 16, 1]);
	
	inputs[| 4] = nodeValue("Gamma", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.6)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	input_display_list = [ 5, 
		["Effect settings", false], 0, 2, 1, 
		["Auto color",		false], 3, 4 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() {
		var _use_pal = inputs[| 2].getValue();
		
		inputs[| 1].setVisible(_use_pal);
		inputs[| 3].setVisible(!_use_pal);
		inputs[| 4].setVisible(!_use_pal);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _gra     = _data[1];
		var _use_gra = _data[2];
		
		if(_use_gra) {
			var _colors = array_create(array_length(_gra) * 4);
			for(var i = 0; i < array_length(_gra); i++) {
				_colors[i * 4 + 0] = color_get_red(_gra[i]) / 255;
				_colors[i * 4 + 1] = color_get_green(_gra[i]) / 255;
				_colors[i * 4 + 2] = color_get_blue(_gra[i]) / 255;
				_colors[i * 4 + 3] = 1;
			}
		
			surface_set_target(_outSurf);
				DRAW_CLEAR
				BLEND_OVERRIDE;
				
				shader_set(sh_posterize_palette);
				shader_set_uniform_f_array_safe(uniform_color, _colors);
				shader_set_uniform_i(uniform_key, array_length(_gra));
				
				draw_surface_safe(_data[0], 0, 0);
				shader_reset();
				
				BLEND_NORMAL;
			surface_reset_target();
		} else {
			var _colors = _data[3];
			var _gamma = _data[4];
			
			surface_set_target(_outSurf);
				DRAW_CLEAR
				BLEND_OVERRIDE;
				
				shader_set(sh_posterize);
				shader_set_uniform_i(uniform_colors, _colors);
				shader_set_uniform_f(uniform_gamma, _gamma);
			
				draw_surface_safe(_data[0], 0, 0);
				shader_reset();
				
				BLEND_NORMAL;
			surface_reset_target();
		}
		
		return _outSurf;
	}
}