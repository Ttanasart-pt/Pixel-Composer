function Node_Glow(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Glow";
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	
	inputs[| 1] = nodeValue("Border", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 4, 0.1] });
	
	inputs[| 2] = nodeValue("Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] });
	
	inputs[| 3] = nodeValue("Strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ]});
	
	inputs[| 4] = nodeValue("Color",   self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 5] = nodeValue_Surface("Mask", self);
	
	inputs[| 6] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 7] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 7;
	
	__init_mask_modifier(5); // inputs 8, 9, 
	
	inputs[| 10] = nodeValue_Enum_Button("Mode", self,  0, [ "Greyscale", "Alpha" ]);
		
	inputs[| 11] = nodeValue("Draw original", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 12] = nodeValue_Enum_Button("Side", self,  0, [ "Outer", "Inner" ]);
		
	input_display_list = [ 7, 
		["Surfaces", true], 0, 5, 6, 8, 9, 
		["Glow",	false], 10, 12, 2, 3,
		["Render",	false], 4, 11, 
	]
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static step = function() { __step_mask_modifier(); }
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _border   = _data[1];
		var _size     = _data[2];
		var _strength = _data[3];
		var _color    = _data[4];
		var _mode     = _data[10];
		var _render   = _data[11];
		var _side     = _data[12];
		
		surface_set_shader(_outSurf, sh_glow);
			shader_set_dim("dimension", _data[0]);
			shader_set_i("mode",      _mode);
			shader_set_f("border",    _border);
			shader_set_f("size",      _size);
			shader_set_f("strength",  _strength);
			shader_set_color("color", _color);
			shader_set_i("render",    _render);
			shader_set_i("side",      _side);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[5], _data[6]);
		
		return _outSurf;
	}
}