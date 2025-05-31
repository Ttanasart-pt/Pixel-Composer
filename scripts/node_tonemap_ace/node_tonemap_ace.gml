function Node_Tonemap_ACE(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "ACE";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	newInput(1, nodeValue_Surface("Mask"));
	
	newInput(2, nodeValue_Slider("Mix", 1));
	
	newActiveInput(3);
	
	newInput(4, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(1, 5); // inputs 5, 6
	
	input_display_list = [ 3, 4, 
		["Surfaces", true], 0, 1, 2, 5, 6, 
	]
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static processData = function(_outSurf, _data, _array_index) {
		
		surface_set_shader(_outSurf, sh_ace);
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return _outSurf;
	}
}