function Node_Curve(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Curve";
	
	shader = sh_curve;
	uniform_wcur = shader_get_uniform(shader, "w_curve");
	uniform_wamo = shader_get_uniform(shader, "w_amount");
	
	uniform_rcur = shader_get_uniform(shader, "r_curve");
	uniform_ramo = shader_get_uniform(shader, "r_amount");
	
	uniform_gcur = shader_get_uniform(shader, "g_curve");
	uniform_gamo = shader_get_uniform(shader, "g_amount");
	
	uniform_bcur = shader_get_uniform(shader, "b_curve");
	uniform_bamo = shader_get_uniform(shader, "b_amount");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Brightness", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_01);
	
	inputs[| 2] = nodeValue("Red", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_01);
	
	inputs[| 3] = nodeValue("Green", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_01);
	
	inputs[| 4] = nodeValue("Blue", self, JUNCTION_CONNECT.input, VALUE_TYPE.curve, CURVE_DEF_01);
	
	inputs[| 5] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 6] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 7] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 7;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 7, 
		["Output",	 true],	0, 5, 6, 
		["Curve",	false],	1, 2, 3, 4, 
	];
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {		
		var _wcur = _data[1];
		var _rcur = _data[2];
		var _gcur = _data[3];
		var _bcur = _data[4];
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		shader_set(shader);
			shader_set_uniform_f_array_safe(uniform_wcur, _wcur);
			shader_set_uniform_i(uniform_wamo, array_length(_wcur));
			shader_set_uniform_f_array_safe(uniform_rcur, _rcur);
			shader_set_uniform_i(uniform_ramo, array_length(_rcur));
			shader_set_uniform_f_array_safe(uniform_gcur, _gcur);
			shader_set_uniform_i(uniform_gamo, array_length(_gcur));
			shader_set_uniform_f_array_safe(uniform_bcur, _bcur);
			shader_set_uniform_i(uniform_bamo, array_length(_bcur));
			
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		
		return _outSurf;
	}
}
