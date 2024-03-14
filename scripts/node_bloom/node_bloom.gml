function Node_Bloom(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Bloom";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	inputs[| 1] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3, "Bloom blur radius.")
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 32, 1] });
	
	inputs[| 2] = nodeValue("Tolerance", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5, "How bright a pixel should be to start blooming.")
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, .25, "Blend intensity.")
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01] });
		
	inputs[| 4] = nodeValue("Bloom mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 5] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 6] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 7;
	
	inputs[| 8] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(5); // inputs 9, 10
	
	input_display_list = [ 7, 8, 
		["Surfaces", true],	0, 5, 6, 9, 10, 
		["Bloom",	false],	1, 2, 3, 4,
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	surface_blur_init();
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _size = _data[1];
		var _tole = _data[2];
		var _stre = _data[3];
		var _mask = _data[4];
		var pass1 = surface_create_valid(surface_get_width_safe(_outSurf), surface_get_height_safe(_outSurf), attrDepth());	
		
		surface_set_shader(pass1, sh_bloom_pass);
			draw_clear_alpha(c_black, 1);
			shader_set_f("size",      _size);
			shader_set_f("tolerance", _tole);
				
			shader_set_i("useMask", is_surface(_mask));
			shader_set_surface("mask", _mask);
				
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		var pass1blur = surface_apply_gaussian(pass1, _size, true, c_black, 1);
		surface_free(pass1);
		
		surface_set_shader(_outSurf, sh_blend_add_alpha_adj);
			shader_set_surface("fore", pass1blur);
			shader_set_f("opacity",	   _stre);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[8]);
		
		return _outSurf;
	}
}