function Node_Dither(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	static dither2 = [  0,  2,
					    3,  1 ];
	static dither4 = [  0,  8,  2, 10,
					   12,  4, 14,  6,
					    3, 11,  1,  9,
					   15,  7, 13,  5];
	static dither8 = [  0, 32,  8, 40,  2, 34, 10, 42, 
					   48, 16, 56, 24, 50, 18, 58, 26,
					   12, 44,  4, 36, 14, 46,  6, 38, 
					   60, 28, 52, 20, 62, 30, 54, 22,
					    3, 35, 11, 43,  1, 33,  9, 41,
					   51, 19, 59, 27, 49, 17, 57, 25,
					   15, 47,  7, 39, 13, 45,  5, 37,
					   63, 31, 55, 23, 61, 29, 53, 21];
	
	name = "Dither";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 2] = nodeValue("Pattern", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "2 x 2 Bayer", "4 x 4 Bayer", "8 x 8 Bayer", "Custom" ]);
	
	inputs[| 3] = nodeValue("Dither map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(false);
	
	inputs[| 4] = nodeValue("Contrast", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 5, 0.1] });
	
	inputs[| 5] = nodeValue("Contrast map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 6] = nodeValue("Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Color", "Alpha" ]);
	
	inputs[| 7] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 8] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 9] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 9;
	
	inputs[| 10] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(7); // inputs 11, 12, 
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 9, 10, 
		["Surfaces", true], 0, 7, 8, 11, 12, 
		["Pattern",	false], 2, 3, 
		["Dither",	false], 6, 1, 4, 5
	]
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
		
		var _type = getInputData(2);
		var _mode = getInputData(6);
		
		inputs[| 3].setVisible(_type == 3, _type == 3);
		inputs[| 1].setVisible(_mode == 0);
		inputs[| 4].setVisible(_mode == 0);
		inputs[| 5].setVisible(_mode == 0);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pal    = _data[1];
		var _typ    = _data[2];
		var _map    = _data[3];
		var _con    = _data[4];
		var _conMap = _data[5];
		var _mode   = _data[6];
		
		surface_set_shader(_outSurf, _mode? sh_alpha_hash : sh_dither);
			shader_set_f("dimension", surface_get_dimension(_data[0]));
			
			switch(_typ) {
				case 0 :
					shader_set_i("useMap",		0);
					shader_set_f("ditherSize",	2);
					shader_set_f("dither",		dither2);
					break;
				case 1 :
					shader_set_i("useMap",		0);
					shader_set_f("ditherSize",	4);
					shader_set_f("dither",		dither4);
					break;
				case 2 :
					shader_set_i("useMap",		0);
					shader_set_f("ditherSize",	8);
					shader_set_f("dither",		dither8);
					break;
				case 3 :
					if(is_surface(_map)) {
						shader_set_i("useMap",		 1);
						shader_set_f("mapDimension", surface_get_dimension(_map));
						shader_set_surface("map",	 _map);
					}
					break;
			}
			
			if(_mode == 0) {
				shader_set_f("contrast",     _con);
				shader_set_i("useConMap",    is_surface(_conMap));
				shader_set_surface("conMap", _conMap);
				
				shader_set_f("palette",		 paletteToArray(_pal));
				shader_set_i("keys",		 array_length(_pal));
			}
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[7], _data[8]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[10]);
		
		return _outSurf; 
	}
}