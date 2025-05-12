function Node_Colorize(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Colorize";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Gradient("Gradient", self, new gradientObject([ ca_black, ca_white ])))
		.setMappable(11);
		
	newInput(2, nodeValue_Float("Gradient Shift", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, .01 ] })
		.setMappable(10);
	
	newInput(3, nodeValue_Surface("Mask", self));
	
	newInput(4, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Bool("Active", self, true));
		active_index = 5;
	
	newInput(6, nodeValue_Bool("Multiply Alpha", self, true));
	
	newInput(7, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	__init_mask_modifier(3); // inputs 8, 9, 
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(10, nodeValueMap("Gradient shift map", self));
	
	newInput(11, nodeValueMap("Gradient map", self));
	
	newInput(12, nodeValueGradientRange("Gradient map range", self, inputs[1]));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(13, nodeValue_Bool("Keep Alpha", self, true));
	
	input_display_list = [ 5, 7, 
		["Surfaces",	 true], 0, 3, 4, 8, 9, 
		["Colorize",	false], 1, 11, 2, 10, 6, 13, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _dim = surface_get_dimension(getSingleValue(0));
		InputDrawOverlay(inputs[12].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, _dim));
		
		return w_hovering;
	}
	
	static step = function() {
		__step_mask_modifier();
		
		inputs[1].mappableStep();
		inputs[2].mappableStep();
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _mlAlp = _data[ 6];
		var _kpAlp = _data[13];
		
		surface_set_shader(_outSurf, sh_colorize);
			shader_set_gradient(_data[1], _data[11], _data[12], inputs[1]);
			
			shader_set_f_map("gradient_shift", _data[2], _data[10], inputs[2]);
			shader_set_i("multiply_alpha", _mlAlp);
			shader_set_i("keep_alpha",     _kpAlp);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader(); 
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[3], _data[4]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[7]);
		
		return _outSurf;
	}
}