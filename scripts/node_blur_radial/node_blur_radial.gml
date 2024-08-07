function Node_Blur_Radial(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Radial Blur";
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue_Rotation("Strength", self, 45)
		.setMappable(10);
	
	inputs[| 2] = nodeValue_Vector("Center",   self, [ 0.5, 0.5 ])
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
		
	inputs[| 3] = nodeValue_Enum_Scroll("Oversample mode", self, 0, [ "Empty", "Clamp", "Repeat" ])
		.setTooltip("How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.");
		
	inputs[| 4] = nodeValue_Surface("Mask", self);
	
	inputs[| 5] = nodeValue_Float("Mix", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 6] = nodeValue_Bool("Active", self, true);
		active_index = 6;
	
	inputs[| 7] = nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(4); // inputs 8, 9, 
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 10] = nodeValueMap("Strength map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 11] = nodeValue_Bool("Gamma Correction", self, false);
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 6, 7, 
		["Surfaces", true],	0, 4, 5, 8, 9, 
		["Blur",	false],	1, 10, 2, 11, 
	];
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var pos  = getInputData(2);
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		var _hov = false;
		
		var hv = inputs[| 1].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); _hov |= hv;
		var hv = inputs[| 2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	} #endregion
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[| 1].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {		
		var _cen  = _data[2];
		
		_cen = array_clone(_cen);
		_cen[0] /= surface_get_width_safe(_outSurf);
		_cen[1] /= surface_get_height_safe(_outSurf);
		
		surface_set_shader(_outSurf, sh_blur_radial);
			shader_set_interpolation(_data[0]);
			shader_set_f("dimension", surface_get_width_safe(_outSurf), surface_get_height_safe(_outSurf));
			shader_set_f_map("strength", _data[1], _data[10], inputs[| 1]);
			shader_set_2("center",       _cen);
			shader_set_f("gamma",        _data[11]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[4], _data[5]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[7]);
		
		return _outSurf;
	}
}