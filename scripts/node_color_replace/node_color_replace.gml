function Node_Color_replace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Replace Palette";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	inputs[| 1] = nodeValue("Palette from", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, array_clone(DEF_PALETTE), "Color to be replaced.")
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 2] = nodeValue("Palette to", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, array_clone(DEF_PALETTE), "Palette to be replaced to.")
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 3] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 4] = nodeValue("Set others to black", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Set pixel that doesn't match any color in 'palette from' to black.");
	
	inputs[| 5] = nodeValue("Multiply alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 6] = nodeValue("Hard replace", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Completely override pixel with new color instead of blending between it.");
	
	inputs[| 7] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 8] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 9] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 9;
	
	inputs[| 10] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
		
	__init_mask_modifier(7); // inputs 11, 12
	
	input_display_list = [ 9, 10, 
		["Surfaces",	 true], 0, 7, 8, 11, 12, 
		["Palette",		false], 1, 2, 
		["Comparison",	false], 3, 5, 
		["Render",		false], 4, 6
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region	
		var fr  = _data[1];
		var to  = _data[2];
		var tr  = _data[3];
		var in  = _data[4];
		var alp = _data[5];
		var hrd = _data[6];
		var msk = _data[7];
		
		var _colorFrom = paletteToArray(fr);
		var _colorTo   = paletteToArray(to);
		
		surface_set_shader(_outSurf, sh_palette_replace);
			shader_set_f("colorFrom",     _colorFrom);
			shader_set_i("colorFrom_amo", array_length(fr));
			shader_set_f("colorTo",		  _colorTo);
			shader_set_i("colorTo_amo",   array_length(to));
			
			shader_set_i("alphacmp",	alp);
			shader_set_i("hardReplace", hrd);
			shader_set_f("treshold",	tr);
			shader_set_i("inverted",	in);
			
			shader_set_i("useMask", is_surface(msk));
			shader_set_surface("mask", msk);
			
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		if(!in) _outSurf = mask_apply(_data[0], _outSurf, _data[7], _data[8]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[10]);
		
		return _outSurf;
	} #endregion
}