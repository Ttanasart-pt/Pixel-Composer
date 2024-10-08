function Node_Kuwahara(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Kuwahara";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
		active_index = 1;
	
	newInput(2, nodeValue_Int("Radius", self, 2))
		.setValidator(VV_min(1));
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(3); // inputs 7, 8
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		["Surfaces", true], 0, 3, 4, 7, 8, 
		["Effects",  true], 2 
	];
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		surface_set_shader(_outSurf, sh_kuwahara);
			shader_set_f("dimension", surface_get_dimension(_data[0]));
			shader_set_i("radius",    _data[2]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	}
}