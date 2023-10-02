function Node_Noise_Simplex(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Simplex Noise";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [0, 0, 0] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [2, 2] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 1] });
	
	inputs[| 4] = nodeValue("Color mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Greyscale", "RGB", "HSV" ]);
	
	inputs[| 5] = nodeValue("Color R range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 6] = nodeValue("Color G range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 7] = nodeValue("Color B range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	input_display_list = [
		["Output",	false], 0, 
		["Noise",	false], 1, 2, 3,
		["Render",	false], 4, 5, 6, 7, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() {
		var _col = getInputData(4);
		
		inputs[| 5].setVisible(_col != 0);
		inputs[| 6].setVisible(_col != 0);
		inputs[| 7].setVisible(_col != 0);
		
		inputs[| 5].name = _col == 1? "Color R range" : "Color H range";
		inputs[| 6].name = _col == 1? "Color G range" : "Color S range";
		inputs[| 7].name = _col == 1? "Color B range" : "Color V range";
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		var _sca = _data[2];
		var _itr = _data[3];
		
		var _col = _data[4];
		var _clr = _data[5];
		var _clg = _data[6];
		var _clb = _data[7];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_simplex);
		shader_set_f("position", _pos);
		shader_set_f("scale", _sca);
		shader_set_i("iteration", _itr);
			
		shader_set_i("colored", _col);
		shader_set_f("colorRanR", _clr);
		shader_set_f("colorRanG", _clg);
		shader_set_f("colorRanB", _clb);
		
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}