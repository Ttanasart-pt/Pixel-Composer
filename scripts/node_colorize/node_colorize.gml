function Node_Colorize(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Colorize";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Gradient", self, JUNCTION_CONNECT.input, VALUE_TYPE.gradient, new gradientObject([ c_black, c_white ]) )
		.setMappable(11);
		
	inputs[| 2] = nodeValue("Gradient shift", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, .01 ] })
		.setMappable(10);
	
	inputs[| 3] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 4] = nodeValue("Mix", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 5] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 5;
	
	inputs[| 6] = nodeValue("Multiply alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 7] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	__init_mask_modifier(3); // inputs 8, 9, 
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 10] = nodeValueMap("Gradient shift map", self);
	
	inputs[| 11] = nodeValueMap("Gradient map", self);
	
	inputs[| 12] = nodeValueGradientRange("Gradient map range", self, inputs[| 1]);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	input_display_list = [ 5, 7, 
		["Surfaces",	 true], 0, 3, 4, 8, 9, 
		["Colorize",	false], 1, 11, 2, 10, 6, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[| 12].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, surface_get_dimension(getSingleValue(0))); _hov |= hv;
		
		return _hov;
	}
	
	static step = function() {
		__step_mask_modifier();
		
		inputs[| 1].mappableStep();
		inputs[| 2].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		surface_set_shader(_outSurf, sh_colorize);
			shader_set_gradient(_data[1], _data[11], _data[12], inputs[| 1]);
			
			shader_set_f_map("gradient_shift", _data[2], _data[10], inputs[| 2]);
			shader_set_i("multiply_alpha",     _data[6]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader(); 
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[7]);
		
		return _outSurf;
	}
}