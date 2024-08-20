function Node_Twirl(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Twirl";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Vec2("Center", self, [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(2, nodeValue_Float("Strength", self, 3))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-10, 10, 0.01] })
		.setMappable(11);
	
	newInput(3, nodeValue_Float("Radius", self, 16))
		.setMappable(12);
	
	newInput(4, nodeValue_Enum_Scroll("Oversample mode", self,  0, [ "Empty", "Clamp", "Repeat" ]))
		.setTooltip("How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.");
		
	newInput(5, nodeValue_Surface("Mask", self));
	
	newInput(6, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(7, nodeValue_Bool("Active", self, true));
		active_index = 7;
	
	newInput(8, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(5); // inputs 9, 10
	
	////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(11, nodeValue_Surface("Strength map", self))
		.setVisible(false, false);
	
	newInput(12, nodeValue_Surface("Radius map", self))
		.setVisible(false, false);
	
	////////////////////////////////////////////////////////////////////////////////////////////
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 7, 8,
		["Surfaces", true],	0, 5, 6, 9, 10, 
		["Twirl",	false],	1, 2, 11, 3, 12,
	];
	
	attribute_surface_depth();
	attribute_oversample();
	attribute_interpolation();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var pos  = current_data[1];
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		var _hov = false;
		
		var  hv  = inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		var  hv  = inputs[3].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() {
		__step_mask_modifier();
		
		inputs[2].mappableStep();
		inputs[3].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region	
		var sam    = struct_try_get(attributes, "oversample");
		
		surface_set_shader(_outSurf, sh_twirl);
		shader_set_interpolation(_data[0]);
			shader_set_f("dimension" , surface_get_width_safe(_data[0]), surface_get_height_safe(_data[0]));
			shader_set_2("center"    ,   _data[1]);
			shader_set_f_map("strength", _data[2], _data[11], inputs[2]);
			shader_set_f_map("radius"  , _data[3], _data[12], inputs[3]);
			shader_set_i("sampleMode",   sam);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[8]);
		
		return _outSurf;
	} #endregion
}