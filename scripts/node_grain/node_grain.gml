function Node_Grain(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grain";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 2] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 3;
	
	inputs[| 4] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(1); // inputs 5, 6
	
	inputs[| 7] = nodeValue("Brightness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(8);
	
	inputs[| 8] = nodeValueMap("Brightness map", self);
	
	inputs[| 9] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[| 9].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 10] = nodeValue("Red", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(11);
	
	inputs[| 11] = nodeValueMap("Red map", self);
		
	inputs[| 12] = nodeValue("Green", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(13);
	
	inputs[| 13] = nodeValueMap("Green map", self);
		
	inputs[| 14] = nodeValue("Blue", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(15);
	
	inputs[| 15] = nodeValueMap("Blue map", self);
		
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 16] = nodeValue("Hue", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(17);
	
	inputs[| 17] = nodeValueMap("Hue map", self);
		
	inputs[| 18] = nodeValue("Saturation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(19);
	
	inputs[| 19] = nodeValueMap("Saturation map", self);
		
	inputs[| 20] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(21);
	
	inputs[| 21] = nodeValueMap("Value map", self);
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 22] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Additive", "Multiply", "Screen", "Overlay" ])
		
	inputs[| 23] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Additive", "Multiply", "Screen" ])
		
	inputs[| 24] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Additive", "Multiply", "Screen" ])
		
	input_display_list = [ 3, 4, 9, 
		["Surfaces",	 true], 0, 1, 2, 5, 6, 
		["Brightness",	false], 22, /**/  7,  8, 
		["RGB",			false], 23, /**/ 10, 11, 12, 13, 14, 15, 
		["HSV",			false], 24, /**/ 16, 17, 18, 19, 20, 21, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
		
		inputs[| 7].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		surface_set_shader(_outSurf, sh_grain);
			shader_set_f("seed", _data[9]);
			shader_set_f_map("brightness", _data[ 7], _data[ 8], inputs[|  7]);
			shader_set_f_map("red",        _data[10], _data[11], inputs[| 10]);
			shader_set_f_map("green",      _data[12], _data[13], inputs[| 12]);
			shader_set_f_map("blue",       _data[14], _data[15], inputs[| 14]);
			
			shader_set_f_map("hue",        _data[16], _data[17], inputs[| 16]);
			shader_set_f_map("sat",        _data[18], _data[19], inputs[| 18]);
			shader_set_f_map("val",        _data[20], _data[21], inputs[| 20]);
			
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