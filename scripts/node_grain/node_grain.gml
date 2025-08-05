function Node_Grain(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Grain";
	
	newActiveInput(3);
	newInput(4, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	newInput(9, nodeValueSeed());
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(1, nodeValue_Surface( "Mask"       ));
	newInput(2, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(1, 5); // inputs 5, 6
	
	////- =Brightness
	newInput(22, nodeValue_Enum_Scroll( "Blend mode", 0, [ "Additive", "Multiply", "Screen", "Overlay" ]))
	newInput( 7, nodeValue_Slider(      "Brightness", 0, [-1,1,.01] )).setHotkey("B").setMappable(8);
	
	////- =RGB
	newInput(23, nodeValue_Enum_Scroll( "Blend mode", 0, [ "Additive", "Multiply", "Screen" ]))
	newInput(10, nodeValue_Slider(      "Red",        0, [-1,1,.01] )).setMappable(11);
	newInput(12, nodeValue_Slider(      "Green",      0, [-1,1,.01] )).setMappable(13);
	newInput(14, nodeValue_Slider(      "Blue",       0, [-1,1,.01] )).setMappable(15);
	
	////- =HSV
	newInput(24, nodeValue_Enum_Scroll( "Blend mode", 0, [ "Additive", "Multiply", "Screen" ]))
	newInput(16, nodeValue_Slider(      "Hue",        0, [-1,1,.01] )).setMappable(17);
	newInput(18, nodeValue_Slider(      "Saturation", 0, [-1,1,.01] )).setMappable(19);
	newInput(20, nodeValue_Slider(      "Value",      0, [-1,1,.01] )).setMappable(21);
		
	// input 25
		
	input_display_list = [ 3, 4, 9, 
		["Surfaces",	 true], 0, 1, 2, 5, 6, 
		["Brightness",	false], 22, /**/  7,  8, 
		["RGB",			false], 23, /**/ 10, 11, 12, 13, 14, 15, 
		["HSV",			false], 24, /**/ 16, 17, 18, 19, 20, 21, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[7].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		
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