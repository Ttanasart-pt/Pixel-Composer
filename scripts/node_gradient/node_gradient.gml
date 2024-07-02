function Node_Gradient(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Gradient";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject([ c_black, c_white ]) )
		.setMappable(15);
	
	inputs[| 2] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ new scrollItem("Linear",   s_node_gradient_type, 0),
												 new scrollItem("Circular", s_node_gradient_type, 1),
												 new scrollItem("Radial",   s_node_gradient_type, 2) ]);
	
	inputs[| 3] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation)
		.setMappable(10);

	inputs[| 4] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, .5)
		.setMappable(11);
		
	inputs[| 5] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-2, 2, 0.01] })
		.setMappable(12);
	
	inputs[| 6] = nodeValue("Center", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.5 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	inputs[| 7] = nodeValue("Loop", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "None", "Loop", "Pingpong" ]);
	
	inputs[| 8] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 9] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 2, 0.01] })
		.setMappable(13);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 10] = nodeValueMap("Angle map", self);
	
	inputs[| 11] = nodeValueMap("Radius map", self);
	
	inputs[| 12] = nodeValueMap("Shift map", self);
	
	inputs[| 13] = nodeValueMap("Scale map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 14] = nodeValue("Uniform ratio", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 15] = nodeValueMap("Gradient map", self);
	
	inputs[| 16] = nodeValueGradientRange("Gradient map range", self, inputs[| 1]);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output",		true],	0, 8, 
		["Gradient",	false], 1, 15, 5, 12, 9, 13, 7, 
		["Shape",		false], 2, 3, 10, 4, 11, 6, 14, 
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		var _hov = false;
		var a = inputs[| 6].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);					active &= !a; _hov |= a;
		var a = inputs[| 16].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, current_data[0]); active &= !a; _hov |= a;
		
		return _hov;
	}
	
	static step = function() {
		var _typ = getInputData(2);
		
		inputs[|  3].setVisible(_typ != 1);
		inputs[|  4].setVisible(_typ == 1);
		inputs[| 14].setVisible(_typ);
		
		inputs[| 1].mappableStep();
		inputs[| 3].mappableStep();
		inputs[| 4].mappableStep();
		inputs[| 5].mappableStep();
		inputs[| 9].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _typ = _data[2];
		var _cnt = _data[6];
		var _lop = _data[7];
		var _msk = _data[8];
		var _uni = _data[14];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_gradient);
			shader_set_gradient(_data[1], _data[15], _data[16], inputs[| 1]);
			
			shader_set_f("dimension",  _dim);
			
			shader_set_i("gradient_loop",  _lop);
			shader_set_f("center", _cnt[0] / _dim[0], _cnt[1] / _dim[1]);
			shader_set_i("type",   _typ);
			shader_set_i("uniAsp", _uni);
			
			shader_set_f_map("angle",  _data[3], _data[10], inputs[| 3]);
			shader_set_f_map("radius", _data[4], _data[11], inputs[| 4]);
			shader_set_f_map("shift",  _data[5], _data[12], inputs[| 5]);
			shader_set_f_map("scale",  _data[9], _data[13], inputs[| 9]);
			
			if(is_surface(_msk)) draw_surface_stretched_ext(_msk, 0, 0, _dim[0], _dim[1], c_white, 1);
			else                 draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}