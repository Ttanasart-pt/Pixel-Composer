function Node_Invert(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Invert";
	
	newActiveInput(3);
	newInput(4, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	newInput(7, nodeValue_Bool(   "Include Alpha", false));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(1, nodeValue_Surface( "Mask"       ));
	newInput(2, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(1, 5); // inputs 5, 6
	// 8
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 4, 7, 
		[ "Surfaces", true ], 0, 1, 2, 5, 6, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {	
	
		surface_set_shader(_outSurf, sh_invert);
			shader_set_i("alpha", _data[7]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return _outSurf;
	}
}