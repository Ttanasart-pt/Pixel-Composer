function Node_Posterize(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Posterize";
	
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
		
	inputs[| 6] = nodeValue("Posterize alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	input_display_list = [ 5, 
		["Effect settings", false], 0, 2, 1, 6, 
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
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _gra     = _data[1];
		var _use_gra = _data[2];
		var _alp     = _data[6];
		
		if(_use_gra) {
			var _colors = array_create(array_length(_gra) * 4);
			for(var i = 0; i < array_length(_gra); i++) {
				_colors[i * 4 + 0] = color_get_red(_gra[i]) / 255;
				_colors[i * 4 + 1] = color_get_green(_gra[i]) / 255;
				_colors[i * 4 + 2] = color_get_blue(_gra[i]) / 255;
				_colors[i * 4 + 3] = 1;
			}
		
			surface_set_shader(_outSurf, sh_posterize_palette);
				shader_set_f("palette", _colors);
				shader_set_i("keys", array_length(_gra));
				shader_set_i("alpha", _alp);
				
				draw_surface_safe(_data[0], 0, 0);
			surface_reset_shader();
		} else {
			var _colors = _data[3];
			var _gamma = _data[4];
			
			surface_set_shader(_outSurf, sh_posterize);
				shader_set_i("colors", _colors);
				shader_set_f("gamma", _gamma);
				shader_set_i("alpha", _alp);
			
				draw_surface_safe(_data[0], 0, 0);
			surface_reset_shader();
		}
		
		return _outSurf;
	}
}