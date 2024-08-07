function Node_Noise_FBM(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "FBM Noise";
	
	inputs[| 0] = nodeValue_Dimension(self);
	
	inputs[| 1] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 1].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 4 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 4] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4);
	
	inputs[| 5] = nodeValue_Enum_Button("Color mode", self,  0, [ "Greyscale", "RGB", "HSV" ]);
	
	inputs[| 6] = nodeValue("Color R range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 7] = nodeValue("Color G range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 8] = nodeValue("Color B range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	input_display_list = [
		["Output",	false], 0, 
		["Noise",	false], 1, 2, 3, 4, 
		["Color",	false], 5, 6, 7, 8, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() {
		var _col = getInputData(5);
		
		inputs[| 6].setVisible(_col != 0);
		inputs[| 7].setVisible(_col != 0);
		inputs[| 8].setVisible(_col != 0);
		
		inputs[| 6].name = _col == 1? "Color R range" : "Color H range";
		inputs[| 7].name = _col == 1? "Color G range" : "Color S range";
		inputs[| 8].name = _col == 1? "Color B range" : "Color V range";
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _sed = _data[1];
		var _pos = _data[2];
		var _sca = _data[3];
		var _itr = _data[4];
		
		var _col = _data[5];
		var _clr = _data[6];
		var _clg = _data[7];
		var _clb = _data[8];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_noise_fbm);
		shader_set_2("position",  _pos);
		shader_set_2("scale",     _sca);
		shader_set_f("seed",      _sed);
		shader_set_i("iteration", _itr);
		
		shader_set_i("colored",   _col);
		shader_set_2("colorRanR", _clr);
		shader_set_2("colorRanG", _clg);
		shader_set_2("colorRanB", _clb);
		
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}