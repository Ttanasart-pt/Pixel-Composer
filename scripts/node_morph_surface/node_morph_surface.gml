function Node_Morph_Surface(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Morph Surface";
	
	newInput(0, nodeValue_Surface("Surface from", self));
	
	newInput(1, nodeValue_Surface("Surface to", self));
	
	newInput(2, nodeValue_Float("Morph amount", self, 0))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Float("Threshold", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 
		["Surfaces", true],	0, 1,
		["Morph",	false],	2, 3, 
	];
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var sFrom = _data[0];
		var sTo   = _data[1];
		var amo   = _data[2];
		var thres = _data[3];
		
		if(!is_surface(sFrom)) return _outSurf;
		if(!is_surface(sTo)) return _outSurf;
		
		surface_set_shader(_outSurf, sh_morph_surface);
		shader_set_interpolation(_data[0]);
			shader_set_surface("sFrom", sFrom);
			shader_set_surface("sTo",   sTo);
			shader_set_f("dimension",   surface_get_width_safe(sFrom), surface_get_height_safe(sTo));
			shader_set_f("amount",      amo);
			shader_set_f("threshold",   thres);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, surface_get_width_safe(sFrom), surface_get_height_safe(sTo));
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}