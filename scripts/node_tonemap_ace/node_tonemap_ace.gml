function Node_Tonemap_ACE(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "ACE";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Surface("Mask", self));
	
	inputs[2] = nodeValue_Float("Mix", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Bool("Active", self, true));
		active_index = 3;
	
	newInput(4, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(1); // inputs 5, 6
	
	input_display_list = [ 3, 4, 
		["Surfaces", true], 0, 1, 2, 5, 6, 
	]
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		surface_set_shader(_outSurf, sh_ace);
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return _outSurf;
	}
}