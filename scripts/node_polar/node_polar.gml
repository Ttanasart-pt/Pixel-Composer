#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Polar", "Radius Mode > Toggle", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[9].setValue((_n.inputs[9].getValue() + 1) % 3); });
	});
#endregion

function Node_Polar(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Polar";
	
	newActiveInput(3);
	newInput(4, nodeValue_Toggle("Channel", 0b1111, { data: array_create(4, THEME.inspector_channel) }));
	
	////- =Surfaces
	
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(1, nodeValue_Surface( "Mask"       ));
	newInput(2, nodeValue_Slider(  "Mix", 1     ));
	__init_mask_modifier(1, 7); // inputs 7, 8, 
	newInput(12, nodeValue_Vec2("Tile", [ 1, 1 ] ));
	
	////- =Effect
	
	newInput(5, nodeValue_Bool(        "Invert",       false))
	newInput(6, nodeValue_Slider(      "Blend",        1)).setMappable(11);
	newInput(9, nodeValue_Enum_Scroll( "Radius Mode",  0, [ new scrollItem("Linear",         s_node_curve_type, 2), 
                                                            new scrollItem("Inverse Square", s_node_curve_type, 1), 
                                                            new scrollItem("Logarithm",      s_node_curve_type, 3), ]));
	newInput(10, nodeValue_Bool( "Swap", false));
	newInput(13, nodeValue_Rotation_Range( "Range", [ 0, 360 ]));
	
	// input 14
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
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