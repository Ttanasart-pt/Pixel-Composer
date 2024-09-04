function Node_Perlin_Smear(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Smear noise";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Vec2("Position", self, [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(2, nodeValue_Vec2("Scale", self, [ 4, 6 ]));
	
	newInput(3, nodeValue_Int("Iteration", self, 3));
	
	newInput(4, nodeValue_Float("Brightness", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Rotation("Rotation", self, 0));
		
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Output",		false], 0, 
		["Noise",		false], 1, 5, 2, 3, 4,
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
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