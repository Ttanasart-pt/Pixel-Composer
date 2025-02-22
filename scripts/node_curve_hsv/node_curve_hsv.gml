function Node_Curve_HSV(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "HSV Curve";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Curve("Hue", self, CURVE_DEF_01));
	
	newInput(2, nodeValue_Curve("Saturation", self, CURVE_DEF_01));
	
	newInput(3, nodeValue_Curve("Value", self, CURVE_DEF_01));
	
	newInput(4, nodeValue_Surface("Mask", self));
	
	newInput(5, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(6, nodeValue_Bool("Active", self, true));
		active_index = 6;
	
	newInput(7, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(4); // inputs 8, 9, 
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 6, 7, 
		["Surfaces", true],	0, 4, 5, 8, 9, 
		["Curve",	false],	1, 2, 3, 
	];
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region	
		var _hcur = _data[1];
		var _scur = _data[2];
		var _vcur = _data[3];
		
		surface_set_shader(_outSurf, sh_curve_hsv);
			shader_set_curve("h_curve", _hcur);
			shader_set_curve("s_curve", _scur);
			shader_set_curve("v_curve", _vcur);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[4], _data[5]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[7]);
		
		return _outSurf;
	} #endregion
}
