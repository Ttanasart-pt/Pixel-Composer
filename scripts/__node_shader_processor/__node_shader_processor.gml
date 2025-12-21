function Node_Shader_Processor(_x, _y, _group = noone) : Node_Shader(_x, _y, _group) constructor {
	name = "";
	
	newActiveInput(5);
	newInput(6, nodeValue_Toggle( "Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(1, nodeValue_Surface( "Mask"       ));
	newInput(2, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(1, 3); // inputs 3, 4
	
	shader_index = array_length(inputs);
	
	input_display_list = [ 5, 6, 
		[ "Surfaces", true ], 0, 1, 2, 3, 4, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	static processShader = function(_outSurf, _data) {
		var _surf = _data[0];
		if(!is_surface(_surf)) return _outSurf;
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		_outSurf = surface_verify(_outSurf, _sw, _sh, attrDepth());
		
		surface_set_shader(_outSurf, shader);
			shader_set_f("dimension", _sw, _sh);
			setShader(_data);
			
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_surf, _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_surf, _outSurf, _data[6]);
		
		return _outSurf;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		return processShader(_outSurf, _data);
	}
}