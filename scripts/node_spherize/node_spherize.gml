function Node_Spherize(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Spherize";
	
	inputs[0] = nodeValue_Surface("Surface in", self);
	
	inputs[1] = nodeValue_Vector("Center", self, [ DEF_SURF_W / 2, DEF_SURF_H / 2 ])
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[2] = nodeValue_Float("Strength", self, 1)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(11);
	
	inputs[3] = nodeValue_Float("Radius", self, 0.2)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(12);
	
	inputs[4] = nodeValue_Enum_Scroll("Oversample mode", self,  0, [ "Empty", "Clamp", "Repeat" ])
		.setTooltip("How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.");
	
	inputs[5] = nodeValue_Surface("Mask", self);
	
	inputs[6] = nodeValue_Float("Mix", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[7] = nodeValue_Bool("Active", self, true);
		active_index = 7;
	
	inputs[8] = nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) });
		
	__init_mask_modifier(5); // inputs 9, 10
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[11] = nodeValue_Surface("Strength map", self)
		.setVisible(false, false);
	
	inputs[12] = nodeValue_Surface("Radius map", self)
		.setVisible(false, false);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[13] = nodeValue_Float("Trim edge", self, 0)
		.setDisplay(VALUE_DISPLAY.slider)
		
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 7, 8, 
		["Surfaces",  true], 0, 5, 6, 9, 10, 
		["Spherize", false], 1, 2, 11, 3, 12, 13, 
	];
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	attributes.oversample  = 2;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		PROCESSOR_OVERLAY_CHECK
		
		var pos  = current_data[1];
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		var _hov = false;
		
		var  hv  = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	} #endregion
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[2].mappableStep();
		inputs[3].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var sam    = struct_try_get(attributes, "oversample");
		
		surface_set_shader(_outSurf, sh_spherize);
		shader_set_interpolation(_data[0]);
			shader_set_f("dimension", [ surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]) ]);
			shader_set_2("center",         _data[1]);
			shader_set_f("trim",           _data[13]);
			shader_set_f_map("strength",   _data[2], _data[11], inputs[2]);
			shader_set_f_map("radius",     _data[3], _data[12], inputs[3]);
			
			shader_set_i("sampleMode", sam);
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[8]);
		
		return _outSurf;
	} #endregion
}