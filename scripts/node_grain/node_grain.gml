function Node_Grain(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grain";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Surface("Mask", self));
	
	newInput(2, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Bool("Active", self, true));
		active_index = 3;
	
	newInput(4, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(1); // inputs 5, 6
	
	newInput(7, nodeValue_Float("Brightness", self, 0))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(8);
	
	newInput(8, nodeValueMap("Brightness map", self));
	
	newInput(9, nodeValue_Float("Seed", self, seed_random(6)))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[9].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(10, nodeValue_Float("Red", self, 0))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(11);
	
	newInput(11, nodeValueMap("Red map", self));
		
	newInput(12, nodeValue_Float("Green", self, 0))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(13);
	
	newInput(13, nodeValueMap("Green map", self));
		
	newInput(14, nodeValue_Float("Blue", self, 0))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(15);
	
	newInput(15, nodeValueMap("Blue map", self));
		
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(16, nodeValue_Float("Hue", self, 0))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(17);
	
	newInput(17, nodeValueMap("Hue map", self));
		
	newInput(18, nodeValue_Float("Saturation", self, 0))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(19);
	
	newInput(19, nodeValueMap("Saturation map", self));
		
	newInput(20, nodeValue_Float("Value", self, 0))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(21);
	
	newInput(21, nodeValueMap("Value map", self));
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(22, nodeValue_Enum_Scroll("Blend mode", self,  0, [ "Additive", "Multiply", "Screen", "Overlay" ]))
		
	newInput(23, nodeValue_Enum_Scroll("Blend mode", self,  0, [ "Additive", "Multiply", "Screen" ]))
		
	newInput(24, nodeValue_Enum_Scroll("Blend mode", self,  0, [ "Additive", "Multiply", "Screen" ]))
		
	input_display_list = [ 3, 4, 9, 
		["Surfaces",	 true], 0, 1, 2, 5, 6, 
		["Brightness",	false], 22, /**/  7,  8, 
		["RGB",			false], 23, /**/ 10, 11, 12, 13, 14, 15, 
		["HSV",			false], 24, /**/ 16, 17, 18, 19, 20, 21, 
	]
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
		
		inputs[7].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		surface_set_shader(_outSurf, sh_grain);
			shader_set_f("seed", _data[9]);
			shader_set_f_map("brightness", _data[ 7], _data[ 8], inputs[ 7]);
			shader_set_f_map("red",        _data[10], _data[11], inputs[10]);
			shader_set_f_map("green",      _data[12], _data[13], inputs[12]);
			shader_set_f_map("blue",       _data[14], _data[15], inputs[14]);
			
			shader_set_f_map("hue",        _data[16], _data[17], inputs[16]);
			shader_set_f_map("sat",        _data[18], _data[19], inputs[18]);
			shader_set_f_map("val",        _data[20], _data[21], inputs[20]);
			
			shader_set_i("bmBright", _data[22]);
			shader_set_i("bmRGB",    _data[23]);
			shader_set_i("bmHSV",    _data[24]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return _outSurf;
	}
}