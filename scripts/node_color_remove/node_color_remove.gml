function Node_Color_Remove(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Remove Color";
	
	shader = sh_color_remove;
	uniform_from       = shader_get_uniform(shader, "colorFrom");
	uniform_from_count = shader_get_uniform(shader, "colorFrom_amo");
	uniform_invert     = shader_get_uniform(shader, "invert");
	
	uniform_ter  = shader_get_uniform(shader, "treshold");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 2] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 4] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	inputs[| 6] = nodeValue("Invert", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Keep the selected colors and remove the rest.");
	
	inputs[| 7] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	input_display_list = [ 5, 7, 
		["Surfaces", true], 0, 3, 4, 
		["Remove",	false], 1, 2, 6, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var frm = _data[1];
		var thr = _data[2];
		var inv = _data[6];
		
		var _colors = [];
		for(var i = 0; i < array_length(frm); i++)
			array_append(_colors, colToVec4(frm[i]));
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		shader_set(shader);
			shader_set_uniform_f_array_safe(uniform_from, _colors);
			shader_set_uniform_i(uniform_from_count, array_length(frm));
			shader_set_uniform_f(uniform_ter, thr);
			shader_set_uniform_i(uniform_invert, inv);
			
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[7]);
		
		return _outSurf;
	} #endregion
}