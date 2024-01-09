function Node_Posterize(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Posterize";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 2] = nodeValue("Use palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 3] = nodeValue("Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4)
		.setDisplay(VALUE_DISPLAY.slider, { range: [2, 16, 1] });
	
	inputs[| 4] = nodeValue("Gamma", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.6)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(7);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
		
	inputs[| 6] = nodeValue("Posterize alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 7] = nodeValueMap("Gamma map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	input_display_list = [ 5, 0, 
		["Palette", false, 2], 1, 3, 4, 7,
		["Alpha",   false, 6], 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() {
		var _use_pal = getInputData(2);
		
		inputs[| 1].setVisible(_use_pal);
		inputs[| 3].setVisible(!_use_pal);
		inputs[| 4].setVisible(!_use_pal);
		inputs[| 4].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _gra     = _data[1];
		var _use_gra = _data[2];
		var _alp     = _data[6];
		
		if(_use_gra) {
			var _colors = paletteToArray(_gra);
			
			surface_set_shader(_outSurf, sh_posterize_palette);
				shader_set_f("palette", _colors);
				shader_set_i("keys", array_length(_gra));
				shader_set_i("alpha", _alp);
				
				draw_surface_safe(_data[0], 0, 0);
			surface_reset_shader();
		} else {
			surface_set_shader(_outSurf, sh_posterize);
				shader_set_i("colors",    _data[3]);
				shader_set_f_map("gamma", _data[4], _data[7], inputs[| 4]);
				shader_set_i("alpha",     _alp);
			
				draw_surface_safe(_data[0], 0, 0);
			surface_reset_shader();
		}
		
		return _outSurf;
	}
}