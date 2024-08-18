function Node_Noise_FBM(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "FBM Noise";
	
	newInput(0, nodeValue_Dimension(self));
	
	inputs[1] = nodeValue_Float("Seed", self, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[1].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	newInput(2, nodeValue_Vec2("Position", self, [ 0, 0 ]));
	
	newInput(3, nodeValue_Vec2("Scale", self, [ 4, 4 ]));
	
	newInput(4, nodeValue_Int("Iteration", self, 4));
	
	newInput(5, nodeValue_Enum_Button("Color mode", self,  0, [ "Greyscale", "RGB", "HSV" ]));
	
	newInput(6, nodeValue_Slider_Range("Color R range", self, [ 0, 1 ]));
	
	newInput(7, nodeValue_Slider_Range("Color G range", self, [ 0, 1 ]));
	
	newInput(8, nodeValue_Slider_Range("Color B range", self, [ 0, 1 ]));
	
	input_display_list = [
		["Output",	false], 0, 
		["Noise",	false], 1, 2, 3, 4, 
		["Color",	false], 5, 6, 7, 8, 
	];
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() {
		var _col = getInputData(5);
		
		inputs[6].setVisible(_col != 0);
		inputs[7].setVisible(_col != 0);
		inputs[8].setVisible(_col != 0);
		
		inputs[6].name = _col == 1? "Color R range" : "Color H range";
		inputs[7].name = _col == 1? "Color G range" : "Color S range";
		inputs[8].name = _col == 1? "Color B range" : "Color V range";
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