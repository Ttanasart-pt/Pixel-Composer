function Node_Dither(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	static dither2 =    [  0,  2,
					       3,  1 ];
	static dither4 =    [  0,  8,  2, 10,
					      12,  4, 14,  6,
					       3, 11,  1,  9,
					      15,  7, 13,  5];
	static dither8 =  [    0, 32,  8, 40,  2, 34, 10, 42, 
						  48, 16, 56, 24, 50, 18, 58, 26,
						  12, 44,  4, 36, 14, 46,  6, 38, 
						  60, 28, 52, 20, 62, 30, 54, 22,
						   3, 35, 11, 43,  1, 33,  9, 41,
						  51, 19, 59, 27, 49, 17, 57, 25,
						  15, 47,  7, 39, 13, 45,  5, 37,
						  63, 31, 55, 23, 61, 29, 53, 21];
	
	name = "Dither";
	
	shader = sh_dither;
	uniform_dither_size	= shader_get_uniform(shader, "ditherSize");
	uniform_dither     	= shader_get_uniform(shader, "dither");
	
	uniform_dim		= shader_get_uniform(shader, "dimension");
	uniform_color	= shader_get_uniform(shader, "palette");
	uniform_key		= shader_get_uniform(shader, "keys");
	
	uniform_constrast	= shader_get_uniform(shader, "contrast");
	uniform_con_map_use = shader_get_uniform(shader, "useConMap");
	uniform_con_map		= shader_get_sampler_index(shader, "conMap");
	
	uniform_map_use = shader_get_uniform(shader, "useMap");
	uniform_map		= shader_get_sampler_index(shader, "map");
	uniform_map_dim = shader_get_uniform(shader, "mapDimension");
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [ c_white ])
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 2] = nodeValue(2, "Pattern", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "2 x 2 Bayer", "4 x 4 Bayer", "8 x 8 Bayer", "Custom" ]);
	
	inputs[| 3] = nodeValue(3, "Dither map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 4] = nodeValue(4, "Contrast", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [1, 5, 0.1]);
	
	inputs[| 5] = nodeValue(5, "Contrast map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _pal = _data[1];
		var _typ = _data[2];
		var _map = _data[3];
		var _con = _data[4];
		var _conMap = _data[5];
		
		var _colors = array_create(array_length(_pal) * 4);
		for(var i = 0; i < array_length(_pal); i++) {
			_colors[i * 4 + 0] = color_get_red(_pal[i]) / 255;
			_colors[i * 4 + 1] = color_get_green(_pal[i]) / 255;
			_colors[i * 4 + 2] = color_get_blue(_pal[i]) / 255;
			_colors[i * 4 + 3] = 1;
		}
		
		surface_set_target(_outSurf);
			draw_clear_alpha(0, 0);
			BLEND_OVER
			
			shader_set(shader);
			shader_set_uniform_f_array(uniform_dim, [ surface_get_width(_data[0]), surface_get_height(_data[0]) ] );
			shader_set_uniform_f_array(uniform_color, _colors);
			shader_set_uniform_i(uniform_key, array_length(_pal));
				
			shader_set_uniform_i(uniform_con_map_use, _conMap == DEF_SURFACE? 0 : 1);
			texture_set_stage(uniform_con_map, surface_get_texture(_conMap));
			shader_set_uniform_f(uniform_constrast, _con);
				
			switch(_typ) {
				case 0 :
					inputs[| 3].setVisible(false);
					shader_set_uniform_i(uniform_map_use, 0);
					shader_set_uniform_f(uniform_dither_size, 2);
					shader_set_uniform_f_array(uniform_dither, dither2);
					break;
				case 1 :
					inputs[| 3].setVisible(false);
					shader_set_uniform_i(uniform_map_use, 0);
					shader_set_uniform_f(uniform_dither_size, 4);
					shader_set_uniform_f_array(uniform_dither, dither4);
					break;
				case 2 :
					inputs[| 3].setVisible(false);
					shader_set_uniform_i(uniform_map_use, 0);
					shader_set_uniform_f(uniform_dither_size, 8);
					shader_set_uniform_f_array(uniform_dither, dither8);
					break;
				case 3 :
					inputs[| 3].setVisible(true);
					if(is_surface(_map)) {
						shader_set_uniform_i(uniform_map_use, 1);
						shader_set_uniform_f_array(uniform_map_dim, [ surface_get_width(_map), surface_get_height(_map) ]);
						texture_set_stage(uniform_map, surface_get_texture(_map));
					}
					break;
			}
			
			draw_surface_safe(_data[0], 0, 0);
			shader_reset();
				
			BLEND_NORMAL 
		surface_reset_target();
		
		return _outSurf; 
	}
}