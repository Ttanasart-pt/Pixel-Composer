function Node_Blur_Zoom(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Zoom Blur";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Float("Strength", self, 0.2))
		.setMappable(12);
	
	newInput(2, nodeValue_Vec2("Center",   self, [ 0.5, 0.5 ]))
		.setUnitRef(function(index) { return getDimension(index); });
		
	newInput(3, nodeValue_Enum_Scroll("Oversample mode", self,  0, [ "Empty", "Clamp", "Repeat" ]))
		.setTooltip("How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.");
		
	newInput(4, nodeValue_Enum_Scroll("Zoom mode", self,  1, [ "Start", "Middle", "End" ]));
		
	newInput(5, nodeValue_Surface("Blur mask", self));
	
	newInput(6, nodeValue_Surface("Mask", self));
	
	newInput(7, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(8, nodeValue_Bool("Active", self, true));
		active_index = 8;
	
	newInput(9, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(6); // inputs 10, 11
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(12, nodeValueMap("Strength map", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(13, nodeValue_Bool("Gamma Correction", self, false));
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 8, 9,
		["Surfaces", true],	0, 6, 7, 10, 11, 
		["Blur",	false],	1, 12, 2, 4, 5, 13
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var pos  = getInputData(2);
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		var _hov = false;
		
		var hv = inputs[1].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny, 0, 64);	_hov |= hv;
		var hv = inputs[2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);			_hov |= hv;
		
		return _hov;
	} #endregion
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[1].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _sam = struct_try_get(attributes, "oversample");
		
		var _cen = array_clone(_data[2]);
		_cen[0] /= surface_get_width_safe(_outSurf);
		_cen[1] /= surface_get_height_safe(_outSurf);
		
		surface_set_shader(_outSurf, sh_blur_zoom);
			shader_set_2("center",       _cen);
			shader_set_f_map("strength", _data[1], _data[12], inputs[1]);
			shader_set_i("blurMode",     _data[4]);
			shader_set_i("sampleMode",   _sam);
			shader_set_i("gamma",        _data[13]);
			
			shader_set_i("useMask", is_surface(_data[5]));
			shader_set_surface("mask", _data[5]);
				
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[6], _data[7]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[9]);
		
		return _outSurf;
	} #endregion
}