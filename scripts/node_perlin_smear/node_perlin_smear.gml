function Node_Perlin_Smear(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Smear noise";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 2] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 4, 6 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Iteration", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 3);
	
	inputs[| 4] = nodeValue("Brightness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output",		false], 0, 
		["Noise",		false], 1, 5, 2, 3, 4,
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[| 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim = _data[0];
		var _pos = _data[1];
		var _sca = _data[2];
		var _ite = _data[3];
		var _bri = _data[4];
		var _rot = _data[5];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_perlin_smear);
			shader_set_f("u_resolution", _dim);
			shader_set_2("position",	 _pos);
			shader_set_2("scale",		 _sca);
			shader_set_f("bright",		 _bri);
			shader_set_i("iteration",	 _ite);
			shader_set_f("rotation",	 degtorad(_rot));
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, c_white, 1);
		surface_reset_shader();
		
		return _outSurf;
	}
}