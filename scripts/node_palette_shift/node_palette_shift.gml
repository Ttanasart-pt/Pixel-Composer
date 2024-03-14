function Node_Palette_Shift(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Palette Shift";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Palette", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE)
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 2] = nodeValue("Shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 1] });
	
	inputs[| 3] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 4] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	inputs[| 6] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
		
	__init_mask_modifier(3); // inputs 7, 8
	
	input_display_list = [ 5, 6, 
		["Surfaces", 	 true], 0, 3, 4, 7, 8, 
		["Palette",		false], 1, 2
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() { #region
		__step_mask_modifier();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _pal = _data[1];
		var _shf = _data[2];
		
		var _colors = [];
		for(var i = 0; i < array_length(_pal); i++)
			array_append(_colors, colToVec4(_pal[i]));
		
		inputs[| 2].editWidget.minn = -array_length(_pal);
		inputs[| 2].editWidget.maxx =  array_length(_pal);
		
		surface_set_shader(_outSurf, sh_palette_shift);
			shader_set_f("palette", _colors);
			shader_set_f("paletteAmount", array_length(_pal));
			shader_set_f("shift", _shf);
			
			draw_surface_safe(_data[0], 0, 0);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	} #endregion
}