function Node_Greyscale(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Greyscale";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(3, nodeValue_Surface( "Mask"       ));
	newInput(4, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(3, 7); // inputs 7, 8
	
	////- =Greyscale
	newInput(1, nodeValue_Slider( "Brightness", 0, [ -1, 1, 0.01] )).setHotkey("B").setMappable(9);
	newInput(2, nodeValue_Slider( "Contrast",   1, [ -1, 4, 0.01] )).setHotkey("C").setMappable(10);
	
	// input 11
	
	input_display_list = [ 5, 6, 
		["Surfaces",	 true], 0, 3, 4, 7, 8, 
		["Greyscale",	false], 1, 9, 2, 10, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _dim = getDimension();
		var _cx = _x + _dim[0] / 2 * _s;
		var _cy = _y + _dim[1] / 2 * _s;
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _cx, _cy - ui(16), _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _cx, _cy + ui(16), _s, _mx, _my, _snx, _sny, 0, _dim[0] / 2));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		
		surface_set_shader(_outSurf, sh_greyscale);
			shader_set_f_map("brightness", _data[1], _data[ 9], inputs[1]);
			shader_set_f_map("contrast",   _data[2], _data[10], inputs[2]);
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	}
}