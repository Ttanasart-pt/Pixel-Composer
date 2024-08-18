function Node_Palette_Shift(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Palette Shift";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Palette("Palette", self, array_clone(DEF_PALETTE)));
	
	newInput(2, nodeValue_Int("Shift", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.1] });
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
		
	__init_mask_modifier(3); // inputs 7, 8
	
	input_display_list = [ 5, 6, 
		["Surfaces", 	 true], 0, 3, 4, 7, 8, 
		["Palette",		false], 1, 2
	]
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
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
		
		inputs[2].editWidget.slide_range[0] = -array_length(_pal);
		inputs[2].editWidget.slide_range[1] =  array_length(_pal);
		
		surface_set_shader(_outSurf, sh_palette_shift);
			shader_set_f("palette", _colors);
			shader_set_f("paletteAmount", array_length(_pal));
			shader_set_f("shift", _shf);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	} #endregion
}