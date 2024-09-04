function Node_Polar(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Polar";
	
	newInput(0, nodeValue_Surface("Surface in", self));
	
	newInput(1, nodeValue_Surface("Mask", self));
	
	newInput(2, nodeValue_Float("Mix", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(3, nodeValue_Bool("Active", self, true));
		active_index = 3;
		
	newInput(4, nodeValue_Toggle("Channel", self, 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	newInput(5, nodeValue_Bool("Invert", self, false))
	
	newInput(6, nodeValue_Float("Blend", self, 1))
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(11);
	
	__init_mask_modifier(1); // inputs 7, 8, 
	
	newInput(9, nodeValue_Enum_Scroll("Radius mode", self,  0, [ new scrollItem("Linear",         s_node_curve, 2), 
												                 new scrollItem("Inverse Square", s_node_curve, 1), 
												                 new scrollItem("Logarithm",      s_node_curve, 3), ]));
	
	newInput(10, nodeValue_Bool("Swap", self, false))
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(11, nodeValueMap("Blend map", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(12, nodeValue_Vec2("Tile", self, [ 1, 1 ] ));
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 4,
		["Surfaces", false], 0, 1, 2, 7, 8, 12, 
		["Effect",   false], 5, 6, 11, 9, 10, 
	]
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static step = function() { #region
		__step_mask_modifier();
		
		inputs[6].mappableStep();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		
		surface_set_shader(_outSurf, sh_polar);
			shader_set_interpolation( _data[0]);
			shader_set_i("invert",    _data[5]);
			shader_set_i("distMode",  _data[9]);
			shader_set_f_map("blend", _data[6], _data[11], inputs[6]);
			shader_set_i("swap",      _data[10]);
			shader_set_2("tile",      _data[12]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return _outSurf;
	}
}