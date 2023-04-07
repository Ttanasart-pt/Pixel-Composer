function Node_Noise(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Noise";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom(99999));
	
	inputs[| 2] = nodeValue("Color mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Greyscale", "RGB", "HSV" ]);
	
	inputs[| 3] = nodeValue("Color R range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, .01]);
	
	inputs[| 4] = nodeValue("Color G range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, .01]);
	
	inputs[| 5] = nodeValue("Color B range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range, [0, 1, .01]);
	
	input_display_list = [
		["Output",	false], 0, 
		["Noise",	false], 1,  
		["Color",	false], 2, 3, 4, 5, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() {
		var _col = inputs[| 2].getValue();
		
		inputs[| 3].setVisible(_col != 0);
		inputs[| 4].setVisible(_col != 0);
		inputs[| 5].setVisible(_col != 0);
		
		inputs[| 3].name = _col == 1? "Color R range" : "Color H range";
		inputs[| 4].name = _col == 1? "Color G range" : "Color S range";
		inputs[| 5].name = _col == 1? "Color B range" : "Color V range";
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _sed = _data[1];
		
		var _col = _data[2];
		var _clr = _data[3];
		var _clg = _data[4];
		var _clb = _data[5];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_noise);
		shader_set_f("seed", _sed);
		
		shader_set_i("colored", _col);
		shader_set_f("colorRanR", _clr);
		shader_set_f("colorRanG", _clg);
		shader_set_f("colorRanB", _clb);
		
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}