function Node_BW(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "BW";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Float("Brightness", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01] })
		.setMappable(9);
	
	newInput(2, nodeValue_Float("Contrast",   self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 4, 0.01] })
		.setMappable(10);
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(3); // inputs 7, 8 
	
	////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(9, nodeValueMap("Brightness map", self));
	
	newInput(10, nodeValueMap("Contrast map", self));
	
	////////////////////////////////////////////////////////////////////////////////////////////////
	
	input_display_list = [ 5, 6, 
		["Surfaces", true], 0, 3, 4, 7, 8, 
		["BW",		false], 1, 9, 2, 10, 
	]
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
		
		inputs[1].mappableStep();
		inputs[2].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		surface_set_shader(_outSurf, sh_bw);
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