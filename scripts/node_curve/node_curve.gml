function Node_Curve(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Curve";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Curve("Brightness", self, CURVE_DEF_01));
	
	newInput(2, nodeValue_Curve("Red", self, CURVE_DEF_01));
	
	newInput(3, nodeValue_Curve("Green", self, CURVE_DEF_01));
	
	newInput(4, nodeValue_Curve("Blue", self, CURVE_DEF_01));
	
	newInput(5, nodeValue_Surface("Mask", self));
	
	newInput(6, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(7, nodeValue_Bool("Active", self, true));
		active_index = 7;
	
	newInput(8, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(5); // inputs 9, 10
	
	newInput(11, nodeValue_Curve("Alpha", self, CURVE_DEF_01));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 7, 8, 
		["Surfaces", true],	0, 5, 6, 9, 10, 
		["Curve",	false],	1, 2, 3, 4, 11, 
	];
	
	attribute_surface_depth();
	
	static step = function() {
		__step_mask_modifier();
	}
	
	static processData = function(_outSurf, _data, _array_index) {	
		var _wcur = _data[1];
		var _rcur = _data[2];
		var _gcur = _data[3];
		var _bcur = _data[4];
		var _acur = _data[11];
		
		surface_set_shader(_outSurf, sh_curve);
			shader_set_curve("w", _wcur);
			shader_set_curve("r", _rcur);
			shader_set_curve("g", _gcur);
			shader_set_curve("b", _bcur);
			shader_set_curve("a", _acur);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[8]);
		
		return _outSurf;
	}
}
