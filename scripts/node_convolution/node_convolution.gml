function Node_Convolution(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Convolution";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Float("Kernel", self, array_create(9)))
		.setDisplay(VALUE_DISPLAY.matrix, { size: 3 });
	
	newInput(2, nodeValue_Enum_Scroll("Oversample mode", self, 0, [ "Empty", "Clamp", "Repeat" ]))
		.setTooltip("How to deal with pixel outside the surface.\n    - Empty: Use empty pixel\n    - Clamp: Repeat edge pixel\n    - Repeat: Repeat texture.");
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(3); // inputs 7, 8, 
	
	newInput(9, nodeValue_Bool("Normalize", self, false));
	
	newInput(10, nodeValue_Int("Size", self, 3))
		.setValidator(VV_clamp(3, 16))
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 5, 6,
		["Surfaces", true],	0, 3, 4, 7, 8, 
		["Kernel",	false],	10, 1, 9, 
	];
	
	attribute_surface_depth();
	attribute_oversample();
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _ker = _data[1];
		var _nrm = _data[9];
		var _siz = max(3, _data[10]);
		
		inputs[1].editWidget.setSize(_siz);
		_ker = array_verify(_ker, _siz * _siz);
		
		surface_set_shader(_outSurf, sh_convolution, true, BLEND.over);
			shader_set_i("sampleMode",  attributes.oversample);
			shader_set_dim("dimension", _outSurf);
			shader_set_f("kernel",      _ker);
			shader_set_i("size",        _siz);
			shader_set_i("normalized",  _nrm);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[6]);
		
		return _outSurf;
	}
}