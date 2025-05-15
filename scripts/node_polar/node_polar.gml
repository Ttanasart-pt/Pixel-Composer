#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Polar", "Radius Mode > Toggle", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 3); });
	});
#endregion

function Node_Polar(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Polar";
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
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
	
	newInput(9, nodeValue_Enum_Scroll("Radius Mode", self,  0, [ new scrollItem("Linear",         s_node_curve_type, 2), 
												                 new scrollItem("Inverse Square", s_node_curve_type, 1), 
												                 new scrollItem("Logarithm",      s_node_curve_type, 3), ]));
	
	newInput(10, nodeValue_Bool("Swap", self, false));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(11, nodeValueMap("Blend Map", self));
	
	//////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(12, nodeValue_Vec2("Tile", self, [ 1, 1 ] ));
	
	newInput(13, nodeValue_Rotation_Range("Range", self, [ 0, 360 ]));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 3, 4,
		["Surfaces", false], 0, 1, 2, 7, 8, 12, 
		["Effect",   false], 5, 6, 11, 9, 10, 13, 
	]
	
	attribute_surface_depth();
	attribute_interpolation();
	
	static processData = function(_outSurf, _data, _array_index) {
		
		surface_set_shader(_outSurf, sh_polar);
			shader_set_interpolation( _data[0]);
			shader_set_i("invert",    _data[5]);
			shader_set_i("distMode",  _data[9]);
			shader_set_f_map("blend", _data[6], _data[11], inputs[6]);
			shader_set_i("swap",      _data[10]);
			shader_set_2("tile",      _data[12]);
			shader_set_2("range",     _data[13]);
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[1], _data[2]);
		_outSurf = channel_apply(_data[0], _outSurf, _data[4]);
		
		return _outSurf;
	}
}