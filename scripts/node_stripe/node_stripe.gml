function Node_Stripe(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Stripe";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] })
		.setMappable(11);
	
	inputs[| 2] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation)
		.setMappable(12);
	
	inputs[| 3] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Solid", "Smooth", "AA" ]);
	
	inputs[| 4] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		
	inputs[| 5] = nodeValue("Random", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(13);
		
	inputs[| 6] = nodeValue("Coloring", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Alternate", "Palette", "Random" ]);
	
	inputs[| 7] = nodeValue("Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) )
		.setMappable(15);
	
	inputs[| 8] = nodeValue("Color 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 9] = nodeValue("Color 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 10] = nodeValue("Strip ratio", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(14);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 11] = nodeValueMap("Amount map", self);
	
	inputs[| 12] = nodeValueMap("Angle map", self);
	
	inputs[| 13] = nodeValueMap("Random map", self);
	
	inputs[| 14] = nodeValueMap("Ratio map", self);
	
	inputs[| 15] = nodeValueMap("Gradient map", self);
	
	inputs[| 16] = nodeValueGradientRange("Gradient map range", self, inputs[| 7]);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 17] = nodeValue("Progress", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 18] = nodeValue("Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, [ c_black, c_white ] )
		.setDisplay(VALUE_DISPLAY.palette);
		
	inputs[| 19] = nodeValueSeed(self, VALUE_TYPE.float);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 19, 
		["Output",	true],	0,  
		["Pattern",	false], 1, 11, 10, 14, 2, 12, 4, 5, 13, 17, 
		["Render",	false], 3, 6, 7, 15, 8, 9, 18, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var pos  = current_data[4];
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		var _hov = false;
		
		var hv = inputs[| 4].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);						active &= !hv; _hov |= hv;
		var hv = inputs[| 2].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny);						active &= !hv; _hov |= hv;
		var hv = inputs[| 16].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, current_data[0]);	active &= !hv; _hov |= hv;
		
		return _hov;
	}
	
	static step = function() {
		var _clr = getSingleValue(6);
		
		inputs[|  1].mappableStep();
		inputs[|  2].mappableStep();
		inputs[|  5].mappableStep();
		inputs[|  7].mappableStep();
		inputs[| 10].mappableStep();
		
		inputs[|  8].setVisible(_clr == 0);
		inputs[|  9].setVisible(_clr == 0);
		inputs[| 18].setVisible(_clr == 1);
		inputs[|  7].setVisible(_clr == 2);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _dim  = _data[0];
		var _bnd  = _data[3];
		var _pos  = _data[4];
		var _clr0 = _data[8];
		var _clr1 = _data[9];
		var _prg  = _data[17];
		var _pal  = _data[18];
		var _seed = _data[19];
		
		var _color = _data[6];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
			
		surface_set_shader(_outSurf, sh_stripe);
			shader_set_f("seed",		 _seed);
			shader_set_f("dimension",	 _dim[0], _dim[1]);
			shader_set_f("position",	 _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_i("blend",		 _bnd);
			shader_set_f("progress",	 _prg);
			
			shader_set_f_map("amount",		 _data[ 1], _data[11], inputs[|  1]);
			shader_set_f_map("angle",		 _data[ 2], _data[12], inputs[|  2]);
			shader_set_f_map("randomAmount", _data[ 5], _data[13], inputs[|  5]);
			shader_set_f_map("ratio",        _data[10], _data[14], inputs[| 10]);
			
			shader_set_i("coloring",	_color);
			
			shader_set_color("color0", _clr0);
			shader_set_color("color1", _clr1);
			shader_set_palette(_pal);
			
			shader_set_gradient(_data[7], _data[15], _data[16], inputs[| 7]);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}