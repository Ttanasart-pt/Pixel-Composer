function Node_Perlin(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Perlin Noise";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 5, 5 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setMappable(10);
	
	inputs[| 3] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 2);
	
	inputs[| 4] = nodeValue("Tile", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		
	inputs[| 5] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom(99999));
		
	inputs[| 6] = nodeValue("Color mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Greyscale", "RGB", "HSV" ]);
	
	inputs[| 7] = nodeValue("Color R range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 8] = nodeValue("Color G range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 9] = nodeValue("Color B range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	//////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 10] = nodeValueMap("Scale map", self);
	
	//////////////////////////////////////////////////////////////////////////////////
	
	input_display_list = [
		["Output", 	 true],	0, 5, 
		["Noise",	false],	1, 2, 10, 3, 4, 
		["Render",	false], 6, 7, 8, 9, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() {
		var _col = getInputData(6);
		
		inputs[| 7].setVisible(_col != 0);
		inputs[| 8].setVisible(_col != 0);
		inputs[| 9].setVisible(_col != 0);
		
		inputs[| 7].name = _col == 1? "Color R range" : "Color H range";
		inputs[| 8].name = _col == 1? "Color G range" : "Color S range";
		inputs[| 9].name = _col == 1? "Color B range" : "Color V range";
		
		inputs[| 2].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		var _ite = _data[3];
		var _til = _data[4];
		var _sed = _data[5];
		
		var _col = _data[6];
		var _clr = _data[7];
		var _clg = _data[8];
		var _clb = _data[9];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_perlin_tiled);
			shader_set_f("u_resolution", _dim);
			shader_set_f("position",     _pos);
			shader_set_f_map("scale",    _data[2], _data[10], inputs[| 2]);
			shader_set_f("seed",         _sed);
			shader_set_i("tile",         _til);
			shader_set_i("iteration",    _ite);
		
			shader_set_i("colored",   _col);
			shader_set_f("colorRanR", _clr);
			shader_set_f("colorRanG", _clg);
			shader_set_f("colorRanB", _clb);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}