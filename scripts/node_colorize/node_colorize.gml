function Node_Colorize(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Colorize";
	
	newActiveInput(5);
	newInput(7, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(3, nodeValue_Surface( "Mask"       ));
	newInput(4, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(3, 8); // inputs 8, 9
	
	////- =Coloize
	
	newInput( 1, nodeValue_Gradient( "Gradient", gra_black_white)).setMappable(11);
	newInput( 2, nodeValue_Slider(   "Gradient Shift", 0, [ -1, 1, .01 ] )).setMappable(10);
	newInput( 6, nodeValue_Bool(     "Multiply Alpha", true ));
	newInput(13, nodeValue_Bool(     "Keep Alpha",     true ));
	
	// input 14
	
	input_display_list = [ 5, 7, 
		["Surfaces",	 true], 0, 3, 4, 8, 9, 
		["Colorize",	false], 1, 11, 2, 10, 6, 13, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _dim = surface_get_dimension(getInputSingle(0));
		InputDrawOverlay(inputs[12].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, _dim));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _mlAlp = _data[ 6];
		var _kpAlp = _data[13];
		
		surface_set_shader(_outSurf, sh_colorize);
			shader_set_gradient(_data[1], _data[11], _data[12], inputs[1]);
			
			shader_set_f_map("gradient_shift", _data[2], _data[10], inputs[2]);
			shader_set_i("multiply_alpha", _mlAlp);
			shader_set_i("keep_alpha",     _kpAlp);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader(); 
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[7]);
		
		return _outSurf;
	}
}