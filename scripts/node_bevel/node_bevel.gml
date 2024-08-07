function Node_Bevel(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Bevel";
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue_Int("Height", self, 4)
		.setMappable(11);
	
	inputs[| 2] = nodeValue_Vector("Shift", self, [ 0, 0 ]);
	
	inputs[| 3] = nodeValue_Vector("Scale", self, [ 1, 1 ] );
	
	inputs[| 4] = nodeValue_Enum_Scroll("Slope", self, 0, [ new scrollItem("Linear",   s_node_curve, 2), 
												            new scrollItem("Smooth",   s_node_curve, 4), 
												            new scrollItem("Circular", s_node_curve, 5), ]);
	
	inputs[| 5] = nodeValue_Surface("Mask", self);
	
	inputs[| 6] = nodeValue_Float("Mix", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue_Bool("Active", self, true);
		active_index = 7;
		
	inputs[| 8] = nodeValue_Enum_Scroll("Oversample mode", self, 0, [ "Empty", "Clamp", "Repeat" ])
		.setTooltip("How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.");
		
	__init_mask_modifier(5); // inputs 9, 10
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 11] = nodeValueMap("Height map", self);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 7, 
		["Surfaces",	 true], 0, 5, 6, 9, 10, 
		["Bevel",		false], 4, 1, 11, 
		["Transform",	false], 2, 3, 
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		PROCESSOR_OVERLAY_CHECK
		
		var _surf = current_data[0];
		if(!is_surface(_surf)) return false;
		
		var _pw = surface_get_width_safe(_surf) * _s / 2;
		var _ph = surface_get_height_safe(_surf) * _s / 2;
		var _hov = false;
		
		var hv = inputs[| 2].drawOverlay(hover, active, _x + _pw, _y + _ph, _s, _mx, _my, _snx, _sny); _hov |= hv;
		
		return _hov;
	} #endregion
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[| 1].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _hei = _data[1];
		var _shf = _data[2];
		var _sca = _data[3];
		var _slp = _data[4];
		var _sam = struct_try_get(attributes, "oversample");
		var _dim = surface_get_dimension(_data[0]);
		
		surface_set_shader(_outSurf, max(_dim[0], _dim[1]) < 256? sh_bevel : sh_bevel_highp);
			shader_set_f("dimension",  _dim);
			shader_set_f_map("height", _hei, _data[11], inputs[| 1]);
			shader_set_2("shift",      _shf);
			shader_set_2("scale",      _sca);
			shader_set_i("slope",      _slp);
			shader_set_i("sampleMode", _sam);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		
		return _outSurf;
	}
}