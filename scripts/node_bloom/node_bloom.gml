function Node_Bloom(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Bloom";
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	inputs[| 1] = nodeValue_Float("Size", self, 3, "Bloom blur radius.")
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 32, 0.1] });
	
	inputs[| 2] = nodeValue_Float("Tolerance", self, 0.5, "How bright a pixel should be to start blooming.")
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue_Float("Strength", self, .25, "Blend intensity.")
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01] });
		
	inputs[| 4] = nodeValue_Surface("Bloom mask", self);
	
	inputs[| 5] = nodeValue_Surface("Mask", self);
	
	inputs[| 6] = nodeValue_Float("Mix", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue_Bool("Active", self, true);
		active_index = 7;
	
	inputs[| 8] = nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(5); // inputs 9, 10
	
	inputs[| 11] = nodeValue_Float("Aspect Ratio", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 12] = nodeValue_Rotation("Direction", self, 0);
	
	inputs[| 13] = nodeValue_Enum_Scroll("Types", self, 0, [ "Gaussian", "Zoom" ]);
	
	inputs[| 14] = nodeValue_Vector("Zoom Origin", self, [ 0.5, 0.5 ])
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
		
	input_display_list = [ 7, 8, 
		["Surfaces",  true], 0, 5, 6, 9, 10, 
		["Bloom",	 false], 1, 2, 3, 4,
		["Blur",	 false], 13, 11, 12, 14, 
	]
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	temp_surface = [ 0 ];
	
	attribute_surface_depth();
	surface_blur_init();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _typ = getSingleValue(13);
		var _hov = false;
		
		if(_typ == 1) { var hv = inputs[| 14].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv; }
		
		return _hov;
	} #endregion
	
	static step = function() { #region
		__step_mask_modifier();
		
		var _typ = getSingleValue(13);
		inputs[| 11].setVisible(_typ == 0);
		inputs[| 12].setVisible(_typ == 0);
		inputs[| 14].setVisible(_typ == 1);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf  = _data[0];
		var _size  = _data[1];
		var _tole  = _data[2];
		var _stre  = _data[3];
		var _mask  = _data[4];
		
		var _type  = _data[13];
		var _ratio = _data[11];
		var _angle = _data[12];
		var _zoom  = _data[14];
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		temp_surface[0] = surface_verify(temp_surface[0], _sw, _sh);	
		
		surface_set_shader(temp_surface[0], sh_bloom_pass);
			draw_clear_alpha(c_black, 1);
			shader_set_f("size",      _size);
			shader_set_f("tolerance", _tole);
				
			shader_set_i("useMask",    is_surface(_mask));
			shader_set_surface("mask", _mask);
				
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		var pass1blur;
		
		     if(_type == 0) pass1blur = surface_apply_gaussian( temp_surface[0], _size, true, c_black, 1, noone, false, _ratio, _angle);
		else if(_type == 1) pass1blur = surface_apply_blur_zoom(temp_surface[0], _size, _zoom[0], _zoom[1], 2, 1);
		
		surface_set_shader(_outSurf, sh_blend_add_alpha_adj);
			shader_set_surface("fore", pass1blur);
			shader_set_f("opacity",	   _stre);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[5], _data[6]);
		_outSurf = channel_apply(_surf, _outSurf, _data[8]);
		
		return _outSurf;
	}
}