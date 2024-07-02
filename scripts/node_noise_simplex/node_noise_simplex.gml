function Node_Noise_Simplex(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Simplex Noise";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 1, 1 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setMappable(8);
	
	inputs[| 3] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1 )
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] })
		.setMappable(9);
	
	inputs[| 4] = nodeValue("Color mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Greyscale", "RGB", "HSV" ]);
	
	inputs[| 5] = nodeValue("Color R range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 6] = nodeValue("Color G range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	inputs[| 7] = nodeValue("Color B range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
	
	//////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 8] = nodeValueMap("Scale map", self);
	
	inputs[| 9] = nodeValueMap("Iteration map", self);
	
	//////////////////////////////////////////////////////////////////////////////////
		
	inputs[| 10] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	input_display_list = [
		["Output",	false], 0, 
		["Noise",	false], 1, 10, 2, 8, 3, 9, 
		["Render",	false], 4, 5, 6, 7, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() { #region
		var _col = getInputData(4);
		
		inputs[| 5].setVisible(_col != 0);
		inputs[| 6].setVisible(_col != 0);
		inputs[| 7].setVisible(_col != 0);
		
		inputs[| 5].name = _col == 1? "Color R range" : "Color H range";
		inputs[| 6].name = _col == 1? "Color G range" : "Color S range";
		inputs[| 7].name = _col == 1? "Color B range" : "Color V range";
		
		inputs[| 2].mappableStep();
		inputs[| 3].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		
		var _col = _data[4];
		var _clr = _data[5];
		var _clg = _data[6];
		var _clb = _data[7];
		var _ang = _data[10];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_simplex);
			shader_set_f("dimension", _dim);
			shader_set_3("position",  _pos);
			shader_set_f("rotation",  degtorad(_ang));
			shader_set_f_map("scale",     _data[2], _data[8], inputs[| 2]);
			shader_set_f_map("iteration", _data[3], _data[9], inputs[| 3]);
			
			shader_set_i("colored",   _col);
			shader_set_2("colorRanR", _clr);
			shader_set_2("colorRanG", _clg);
			shader_set_2("colorRanB", _clb);
		
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[| 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
}