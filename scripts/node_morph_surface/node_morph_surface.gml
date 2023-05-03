function Node_Morph_Surface(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Morph Surface";
	
	inputs[| 0] = nodeValue("Surface from", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Surface to", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 2] = nodeValue("Morph amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	inputs[| 3] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 
		["Output",	 true],	0, 1,
		["Morph",	false],	2, 3, 
	];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {		
		var sFrom = _data[0];
		var sTo   = _data[1];
		var amo   = _data[2];
		var thres = _data[3];
		
		if(!is_surface(sFrom)) return _outSurf;
		if(!is_surface(sTo)) return _outSurf;
		
		surface_set_shader(_outSurf, sh_morph_surface);
		shader_set_interpolation(_data[0]);
			shader_set_surface("sFrom", sFrom);
			shader_set_surface("sTo", sTo);
			shader_set_f("dimension", surface_get_width(sFrom), surface_get_height(sTo));
			shader_set_f("amount", amo);
			shader_set_f("threshold", thres);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, surface_get_width(sFrom), surface_get_height(sTo));
		surface_reset_shader();
		
		return _outSurf;
	}
}