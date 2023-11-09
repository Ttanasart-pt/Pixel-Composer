function Node_Color_replace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Replace Palette";
	
	shader = sh_palette_replace;
	uniform_from       = shader_get_uniform(shader, "colorFrom");
	uniform_from_count = shader_get_uniform(shader, "colorFrom_amo");
	
	uniform_to		   = shader_get_uniform(shader, "colorTo");
	uniform_to_count   = shader_get_uniform(shader, "colorTo_amo");
	
	uniform_ter  = shader_get_uniform(shader, "treshold");
	uniform_alp  = shader_get_uniform(shader, "alphacmp");
	uniform_inv  = shader_get_uniform(shader, "inverted");
	uniform_hrd  = shader_get_uniform(shader, "hardReplace");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue("Palette from", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE, "Color to be replaced.")
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 2] = nodeValue("Palette to", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE, "Palette to be replaced to.")
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 3] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 4] = nodeValue("Set others to black", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Set pixel that doesn't match any color in 'palette from' to black.");
	
	inputs[| 5] = nodeValue("Multiply alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 6] = nodeValue("Hard replace", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true, "Completely override pixel with new color instead of blending between it.");
	
	inputs[| 7] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 8] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 9] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 9;
	
	inputs[| 10] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
		
	input_display_list = [ 9, 10, 
		["Surfaces",	 true], 0, 7, 8, 
		["Palette",		false], 1, 2, 
		["Comparison",	false], 3, 5, 
		["Render",		false], 4, 6
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region	
		var fr  = _data[1];
		var to  = _data[2];
		var tr  = _data[3];
		var in  = _data[4];
		var alp = _data[5];
		var hrd = _data[6];
		var msk = _data[7];
		
		var _colorFrom = array_create(array_length(fr) * 4);
		for(var i = 0; i < array_length(fr); i++) {
			_colorFrom[i * 4 + 0] = color_get_red(fr[i]) / 255;
			_colorFrom[i * 4 + 1] = color_get_green(fr[i]) / 255;
			_colorFrom[i * 4 + 2] = color_get_blue(fr[i]) / 255;
			_colorFrom[i * 4 + 3] = 1;
		}
		
		var _colorTo = array_create(array_length(to) * 4);
		for(var i = 0; i < array_length(to); i++) {
			_colorTo[i * 4 + 0] = color_get_red(to[i]) / 255;
			_colorTo[i * 4 + 1] = color_get_green(to[i]) / 255;
			_colorTo[i * 4 + 2] = color_get_blue(to[i]) / 255;
			_colorTo[i * 4 + 3] = 1;
		}
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		shader_set(shader);
			shader_set_uniform_f_array_safe(uniform_from, _colorFrom);
			shader_set_uniform_i(uniform_from_count, array_length(fr));
			shader_set_uniform_i(uniform_alp, alp);
			shader_set_uniform_i(uniform_hrd, hrd);
			
			shader_set_uniform_f_array_safe(uniform_to, _colorTo);
			shader_set_uniform_i(uniform_to_count, array_length(to));
			shader_set_uniform_f(uniform_ter, tr);
			shader_set_uniform_i(uniform_inv, in);
			
			shader_set_i("useMask", is_surface(msk));
			shader_set_surface("mask", msk);
			
			draw_surface_safe(_data[0], 0, 0);
		shader_reset();
		
		BLEND_NORMAL
		surface_reset_target();
		
		if(!in) _outSurf = mask_apply(_data[0], _outSurf, _data[7], _data[8]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[10]);
		
		return _outSurf;
	} #endregion
}