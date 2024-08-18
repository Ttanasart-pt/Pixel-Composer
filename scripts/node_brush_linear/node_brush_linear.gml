function Node_Brush_Linear(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Brush";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Bool("Active", self, true));
		active_index = 1;
	
	newInput(2, nodeValue_Int("Iteration", self, 10))
		.setValidator(VV_min(1));
	
	newInput(3, nodeValue_Float("Seed", self, seed_random(6)))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { randomize(); inputs[3].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) })
	
	newInput(4, nodeValue_Float("Length", self, 10));
	
	newInput(5, nodeValue_Float("Attenuation", self, 0.99))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(6, nodeValue_Float("Circulation", self, 0.8))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(7, nodeValue_Surface("Mask", self));
	
	newInput(8, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(9, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(7); // inputs 10, 11
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 1,
		["Surface", false], 0, 7, 8, 9, 10, 11, 
		["Effect",  false], 2, 4, 5, 6, 
	];
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		surface_set_shader(_outSurf, sh_brush_linear);
			shader_set_f("dimension",             surface_get_dimension(_data[0]));
			shader_set_f("seed",                  _data[3]);
			shader_set_i("convStepNums",          _data[2]);
			shader_set_f("itrStepPixLen",         _data[4]);
			shader_set_f("distanceAttenuation",   _data[5]);
			shader_set_f("vectorCirculationRate", _data[6]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[7], _data[8]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[9]);
		
		return _outSurf;
	}
}