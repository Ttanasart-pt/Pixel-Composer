function Node_Glow(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Glow";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Border", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 4, 1] });
	
	inputs[| 2] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 1] });
	
	inputs[| 3] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 4] = nodeValue("Color",   self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 5] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 6] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 7;
	
	__init_mask_modifier(5); // inputs 8, 9, 
	
	input_display_list = [ 7, 
		["Surfaces", true], 0, 5, 6, 8, 9, 
		["Glow",	false], 1, 2, 3, 4, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	surface_blur_init();
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _border = _data[1];
		var _size = _data[2];
		var _stre = _data[3];
		var cl    = _data[4];
		var pass1 = surface_create_valid(surface_get_width_safe(_outSurf), surface_get_height_safe(_outSurf), attrDepth());	
		
		surface_set_target(pass1);
		draw_clear_alpha(c_black, 1);
			shader_set(sh_outline_only);
				shader_set_f("dimension",  [ surface_get_width_safe(_outSurf), surface_get_height_safe(_outSurf) ]);
				shader_set_f("borderSize", _size + _border);
				shader_set_f("borderColor", [ 1., 1., 1., 1. ]);
				
				if(is_surface(_data[0])) draw_surface_safe(_data[0], 0, 0);
			shader_reset();
		surface_reset_target();
		
		var s = surface_apply_gaussian(pass1, _size, false, c_black, 1, noone);
		
		surface_set_shader(_outSurf, sh_lum2alpha);
			shader_set_color("color", cl);
			shader_set_f("intensity", _stre);
			draw_surface_ext_safe(s, 0, 0, 1, 1, 0, c_white, 1);
		shader_reset();
		
		BLEND_ALPHA_MULP
		draw_surface_safe(_data[0], 0, 0);
		BLEND_NORMAL
		
		surface_reset_target();
		
		surface_free(pass1);
		surface_free(s);
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		
		return _outSurf;
	}
}