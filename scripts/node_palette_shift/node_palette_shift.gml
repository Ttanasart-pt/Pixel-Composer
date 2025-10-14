function Node_Palette_Shift(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Palette Shift";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(3, nodeValue_Surface( "Mask"       ));
	newInput(4, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(3, 7); // inputs 7, 8
	
	////- =Palette
	newInput(1, nodeValue_Palette( "Palette" ));
	newInput(2, nodeValue_Slider(  "Shift",   0, [-1, 1, 0.1] )).setHotkey("S");
	// input 9
	
	input_display_list = [ 5, 6, 
		["Surfaces", 	 true], 0, 3, 4, 7, 8, 
		["Palette",		false], 1, 2
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy, _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
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
	}
}