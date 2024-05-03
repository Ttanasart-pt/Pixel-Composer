function Node_Posterize(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Posterize";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, array_clone(DEF_PALETTE))
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 2] = nodeValue("Use palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 3] = nodeValue("Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4)
		.setDisplay(VALUE_DISPLAY.slider, { range: [2, 16, 0.1] });
	
	inputs[| 4] = nodeValue("Gamma", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.6)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(7);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
		
	inputs[| 6] = nodeValue("Posterize alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 7] = nodeValueMap("Gamma map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 8] = nodeValue("Space", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "RGB", "LAB" ]);
	
	input_display_list = [ 5, 0, 
		["Palette", false, 2], 1, 3, 4, 7, 8, 
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
		inputs[| 8].setVisible(_use_pal);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pal     = _data[1];
		var _use_pal = _data[2];
		var _alp     = _data[6];
		var _spce    = _data[8];
		
		if(_use_pal) {
			surface_set_shader(_outSurf, sh_posterize_palette);
				shader_set_f("palette", paletteToArray(_pal));
				shader_set_i("keys", array_length(_pal));
				shader_set_i("alpha", _alp);
				shader_set_i("space", _spce);
				
				draw_surface_safe(_data[0]);
			surface_reset_shader();
			
		} else {
			surface_set_shader(_outSurf, sh_posterize);
				shader_set_i("colors",    _data[3]);
				shader_set_f_map("gamma", _data[4], _data[7], inputs[| 4]);
				shader_set_i("alpha",     _alp);
			
				draw_surface_safe(_data[0]);
			surface_reset_shader();
		}
		
		return _outSurf;
	}
}