function Node_Perlin(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Perlin Noise";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Vec2("Position", self, [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(2, nodeValue_Vec2("Scale", self, [ 5, 5 ]))
		.setMappable(10);
	
	newInput(3, nodeValue_Int("Iteration", self, 4));
	
	newInput(4, nodeValue_Bool("Tile", self, true));
		
	newInput(5, nodeValueSeed(self));
		
	newInput(6, nodeValue_Enum_Button("Color mode", self,  0, [ "Greyscale", "RGB", "HSV" ]));
	
	newInput(7, nodeValue_Slider_Range("Color R range", self, [ 0, 1 ]));
	
	newInput(8, nodeValue_Slider_Range("Color G range", self, [ 0, 1 ]));
	
	newInput(9, nodeValue_Slider_Range("Color B range", self, [ 0, 1 ]));
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(10, nodeValueMap("Scale map", self));
	
	//////////////////////////////////////////////////////////////////////////////////
	
	newInput(11, nodeValue_Rotation("Rotation", self, 0));
		
	input_display_list = [
		["Output", 	 true],	0, 5, 
		["Noise",	false],	1, 11, 2, 10, 3, 4, 
		["Render",	false], 6, 7, 8, 9, 
	];
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() {
		var _col = getInputData(6);
		
		inputs[7].setVisible(_col != 0);
		inputs[8].setVisible(_col != 0);
		inputs[9].setVisible(_col != 0);
		
		inputs[7].name = _col == 1? "Color R range" : "Color H range";
		inputs[8].name = _col == 1? "Color G range" : "Color S range";
		inputs[9].name = _col == 1? "Color B range" : "Color V range";
		
		inputs[2].mappableStep();
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
		var _rot = _data[11];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_perlin_tiled);
			shader_set_2("dimension",  _dim);
			shader_set_2("position",   _pos);
			shader_set_f("rotation",   degtorad(_rot));
			shader_set_f_map("scale",  _data[2], _data[10], inputs[2]);
			shader_set_f("seed",       _sed);
			shader_set_i("tile",       _til);
			shader_set_i("iteration",  _ite);
		
			shader_set_i("colored",   _col);
			shader_set_2("colorRanR", _clr);
			shader_set_2("colorRanG", _clg);
			shader_set_2("colorRanB", _clb);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}