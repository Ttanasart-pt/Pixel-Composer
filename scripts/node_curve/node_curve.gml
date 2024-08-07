function Node_Curve(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Curve";
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue("Brightness", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_01);
	
	inputs[| 2] = nodeValue("Red", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_01);
	
	inputs[| 3] = nodeValue("Green", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_01);
	
	inputs[| 4] = nodeValue("Blue", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_01);
	
	inputs[| 5] = nodeValue_Surface("Mask", self);
	
	inputs[| 6] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 7;
	
	inputs[| 8] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(5); // inputs 9, 10
	
	inputs[| 11] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_01);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 7, 8, 
		["Surfaces", true],	0, 5, 6, 9, 10, 
		["Curve",	false],	1, 2, 3, 4, 11, 
	];
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region	
		var _wcur = _data[1];
		var _rcur = _data[2];
		var _gcur = _data[3];
		var _bcur = _data[4];
		var _acur = _data[11];
		
		surface_set_shader(_outSurf, sh_curve);
			shader_set_f("w_curve",  _wcur);
			shader_set_i("w_amount", array_length(_wcur));
									
			shader_set_f("r_curve",  _rcur);
			shader_set_i("r_amount", array_length(_rcur));
									
			shader_set_f("g_curve",  _gcur);
			shader_set_i("g_amount", array_length(_gcur));
									
			shader_set_f("b_curve",  _bcur);
			shader_set_i("b_amount", array_length(_bcur));
			
			shader_set_f("a_curve",  _acur);
			shader_set_i("a_amount", array_length(_acur));
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[8]);
		
		return _outSurf;
	} #endregion
}
