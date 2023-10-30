function Node_Stripe(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Stripe";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] });
	
	inputs[| 2] = nodeValue("Angle", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 3] = nodeValue("Blend", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, 0, "Smoothly blend between each stripe.");
	
	inputs[| 4] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [0, 0] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
		
	inputs[| 5] = nodeValue("Random", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 6] = nodeValue("Random color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 7] = nodeValue("Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject(c_white) );
	
	inputs[| 8] = nodeValue("Color 1", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 9] = nodeValue("Color 2", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 10] = nodeValue("Strip ratio", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 
		["Output",	true],	0,  
		["Pattern",	false], 1, 10, 2, 4, 5,
		["Render",	false], 6, 7, 8, 9, 3
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var pos = getInputData(4);
		var px = _x + pos[0] * _s;
		var py = _y + pos[1] * _s;
		
		inputs[| 4].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		inputs[| 2].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _dim = _data[0];
		var _amo = _data[1];
		var _ang = _data[2];
		var _bnd = _data[3];
		var _pos = _data[4];
		var _rnd = _data[5];
		
		var _clr0 = _data[ 8];
		var _clr1 = _data[ 9];
		var _rat  = _data[10];
		
		var _grad_use = _data[6];
		inputs[| 7].setVisible(_grad_use);
		inputs[| 8].setVisible(!_grad_use);
		inputs[| 9].setVisible(!_grad_use);
		
		var _gra = _data[7];
		
		var _g = _gra.toArray();
		var _grad_color = _g[0];
		var _grad_time = _g[1];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
			
		surface_set_shader(_outSurf, sh_stripe);
			shader_set_f("dimension",	 _dim[0], _dim[1]);
			shader_set_f("position",	 _pos[0] / _dim[0], _pos[1] / _dim[1]);
			shader_set_f("angle",		 degtorad(_ang));
			shader_set_f("amount",		 _amo);
			shader_set_f("blend",		 _bnd);
			shader_set_f("randomAmount", _rnd);
			shader_set_f("ratio",        _rat);
			
			shader_set_f("color0", colToVec4(_clr0));
			shader_set_f("color1", colToVec4(_clr1));
			
			shader_set_i("gradient_use",	_grad_use);
			shader_set_i("gradient_blend",	_gra.type);
			shader_set_f("gradient_color",	_grad_color);
			shader_set_f("gradient_time",	_grad_time);
			shader_set_i("gradient_keys",	array_length(_gra.keys));
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}